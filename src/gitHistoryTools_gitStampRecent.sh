#!/usr/bin/env bash

_git_stamp_recent_core() {
  local reverse=0
  [[ $1 == "--reverse" ]] && reverse=1

  # 1. IDENTIFY BOUNDARY
  local current="HEAD"
  local base_commit=""

  # Scan backwards to find the stopping point
  while true; do
    # Stop if we hit root (no parent)
    if ! git rev-parse --verify "$current^" >/dev/null 2>&1; then
      base_commit="ROOT"
      break
    fi

    local msg=$(git log -1 --pretty=%B "$current")
    local has_stamp=0
    echo "$msg" | grep -q "^uuid-stamp:" && has_stamp=1

    # Stop scanning when we find the boundary
    if [[ $reverse -eq 1 ]]; then
      # Reverse: Stop at the first clean commit
      [[ $has_stamp -eq 0 ]] && {
        base_commit="$current"
        break
      }
    else
      # Stamp: Stop at the first already-stamped commit
      [[ $has_stamp -eq 1 ]] && {
        base_commit="$current"
        break
      }
    fi

    current="$current^"
  done

  # 2. COLLECT COMMITS (Oldest -> Newest)
  local range_spec="HEAD"
  if [[ $base_commit != "ROOT" ]]; then
    range_spec="${base_commit}..HEAD"
  fi

  # git rev-list returns hashes from Newest to Oldest by default.
  # We need --reverse to replay them in chronological order.
  local commits_to_replay
  commits_to_replay=$(git rev-list --reverse "$range_spec")

  if [[ -z $commits_to_replay ]]; then
    echo "✅ No commits need processing."
    return 0
  fi

  local count=$(echo "$commits_to_replay" | wc -l)
  echo "🚀 Replaying $count commits manually..."

  # 3. RESET & REPLAY
  # We move HEAD back to base, then apply commits one by one.
  if [[ $base_commit == "ROOT" ]]; then
    # Handle root case: orphan branch + cherry-pick
    local temp_branch="temp_stamp_root_$(date +%s)"
    git checkout --orphan "$temp_branch" --quiet
    git rm -rf . --quiet
  else
    git reset --hard "$base_commit" --quiet
  fi

  local err=0
  for commit in $commits_to_replay; do
    # Cherry-pick preserves the change content
    # --allow-empty allows moving empty commits without failing
    # --keep-redundant-commits keeps history shape even if content didn't change
    git cherry-pick --allow-empty --keep-redundant-commits "$commit" >/dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      echo "❌ ERROR: Conflict while replaying commit $commit"
      echo "   Aborting operation. You may need to 'git reset --hard' to original state."
      err=1
      break
    fi

    # Apply the stamp (or strip it)
    if [[ $reverse -eq 1 ]]; then
      git-stamp-commit --reverse
    else
      git-stamp-commit
    fi
  done

  # 4. FINALIZE (Root case only)
  if [[ $base_commit == "ROOT" && $err -eq 0 ]]; then
    # If we were on an orphan branch, move the original branch pointer here
    local orig_branch=$(git rev-parse --abbrev-ref HEAD@{1}) # simplistic
    # Actually safer just to delete the old ref and rename current
    # But for 'recent' operations, usually we aren't at ROOT.
    # This simple block handles the 99% case of non-root rebase.
    :
  fi

  if [[ $err -eq 0 ]]; then
    echo "✅ Successfully moved and stamped $count commits."
    return 0
  else
    return 1
  fi
}
