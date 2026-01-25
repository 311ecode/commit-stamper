#!/usr/bin/env bash

git-cherry-pick-stamp() {
  local commit_hash="$1"

  if [[ -z $commit_hash ]]; then
    echo "Usage: git-cherry-pick-stamp <commit-hash>" >&2
    return 1
  fi

  echo "🍒 Cherry-picking $commit_hash with stamp preservation..."

  # 1. Perform the standard cherry-pick without committing immediately
  # This allows us to inspect the message before finalizing
  if ! git cherry-pick -n "$commit_hash"; then
    echo "❌ ERROR: Cherry-pick conflicted. Resolve manually and run git-stamp-commit." >&2
    return 1
  fi

  # 2. Get the original message
  local original_msg
  original_msg=$(git log -1 --pretty=%B "$commit_hash")

  # 3. Commit with the original message (preserving the stamp if it exists)
  # If it doesn't have a stamp, we add one now.
  if echo "$original_msg" | grep -q "^uuid-stamp:"; then
    echo "✅ Original stamp found. Preserving..."
    git commit --no-edit --quiet
  else
    echo "📝 No stamp found in original. Generating new stamp..."
    git commit --no-edit --quiet
    git-stamp-commit
  fi
}
