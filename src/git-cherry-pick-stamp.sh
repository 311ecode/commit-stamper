#!/usr/bin/env bash
git-cherry-pick-stamp() {
  local reverse=0
  local commit_hash=""

  for arg in "$@"; do
    if [[ $arg == "--reverse" ]]; then reverse=1; else commit_hash="$arg"; fi
  done

  if [[ -z $commit_hash ]]; then
    echo "Usage: git-cherry-pick-stamp [--reverse] <commit-hash>" >&2
    return 1
  fi

  if ! git cherry-pick -n "$commit_hash"; then
    echo "❌ ERROR: Cherry-pick conflict. Resolve manually." >&2
    return 1
  fi

  if [[ $reverse -eq 1 ]]; then
    echo "🍒 Cherry-picking and stripping stamp..."
    git commit --no-edit --quiet
    git-stamp-commit --reverse
  else
    # Preserve original stamp if it exists, otherwise generate new
    local original_msg
    original_msg=$(git log -1 --pretty=%B "$commit_hash")
    if echo "$original_msg" | grep -q "^uuid-stamp:"; then
      git commit --no-edit --quiet
    else
      git commit --no-edit --quiet
      git-stamp-commit
    fi
  fi
}
