#!/usr/bin/env bash

_git_stamp_recent_core() {
  local reverse=0
  [[ "$1" == "--reverse" ]] && reverse=1
  
  # Dependency check
  if ! declare -f git-stamp-commit >/dev/null && ! command -v git-stamp-commit >/dev/null; then
    echo "❌ ERROR: git-stamp-commit function/command not found."
    return 1
  fi

  echo "🔍 Scanning recent history..."
  
  local current="HEAD"
  local commits_to_process=() # Stores hashes
  local base_commit=""

  # 1. IDENTIFY COMMITS
  # Scan backwards to find which commits need processing
  while true; do
    # Stop if we hit root
    if ! git rev-parse --verify "$current^" >/dev/null 2>&1; then
      commits_to_process+=($(git rev-parse "$current"))
      base_commit="ROOT"
      break
    fi

    local msg
    msg=$(git log -1 --pretty=%B "$current")
    local has_stamp=0
    echo "$msg" | grep -q "^uuid-stamp:" && has_stamp=1

    if [[ $reverse -eq 1 ]]; then
      # Reverse: Stop at the first commit that is ALREADY CLEAN
      if [[ $has_stamp -eq 0 ]]; then
        base_commit="$current"
        break
      fi
    else
      # Normal: Stop at the first commit that ALREADY HAS STAMP
      if [[ $has_stamp -eq 1 ]]; then
        base_commit="$current"
        break
      fi
    fi

    commits_to_process+=($(git rev-parse "$current"))
    current="$current^"
  done

  local count=${#commits_to_process[@]}
  if [[ $count -eq 0 ]]; then
    echo "✅ Nothing to do."
    return 0
  fi

  echo "🚀 Processing $count commits (Manual Rebase)..."

  # 2. PREPARE REBASE
  # We need to apply commits from OLDEST to NEWEST
  # commits_to_process is currently NEWEST -> OLDEST
  local ordered_commits=()
  for (( i=$count-1; i>=0; i-- )); do
    ordered_commits+=("${commits_to_process[$i]}")
  done

  # 3. RESET HARD
  # Move HEAD back to the base, discarding the recent commits (we will replay them)
  if [[ "$base_commit" == "ROOT" ]]; then
    # Special case: rewriting from the very first commit
    # We create an orphan branch or similar, but easier is to just checkout the first commit
    # and squash/amend. But for "recent" logic, usually we have a parent.
    # Handling ROOT rebase manually in bash is complex. 
    # Fallback to interactive rebase ONLY for ROOT case as it's rare for "recent".
    GIT_SEQUENCE_EDITOR=: git rebase --quiet --root --exec "git-stamp-commit $( [[ $reverse -eq 1 ]] && echo '--reverse' )"
    return $?
  else
    git reset --hard "$base_commit" >/dev/null
  fi

  # 4. REPLAY LOOP
  local err=0
  for commit in "${ordered_commits[@]}"; do
    # Cherry-pick the commit content
    # -n: no commit, allow us to inspect/modify if needed, or just commit cleanly
    git cherry-pick "$commit" >/dev/null 2>&1
    
    # Check for conflict
    if [[ $? -ne 0 ]]; then
      echo "❌ ERROR: Conflict during rebase at commit $commit. Aborting."
      git cherry-pick --abort
      # Try to restore original state? Hard to do perfectly without reflog.
      return 1
    fi

    # Run the stamping function (which does 'git commit --amend')
    # Note: git cherry-pick creates a commit. git-stamp-commit amends it.
    if [[ $reverse -eq 1 ]]; then
      git-stamp-commit --reverse
    else
      git-stamp-commit
    fi
    
    if [[ $? -ne 0 ]]; then
        echo "❌ ERROR: Stamping failed."
        err=1
        break
    fi
  done

  if [[ $err -eq 0 ]]; then
    echo "✅ Done."
    return 0
  else
    return 1
  fi
}
