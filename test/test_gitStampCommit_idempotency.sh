#!/usr/bin/env bash

test_gitStampCommit_idempotency() {
  echo "🧪 Testing Stamping Idempotency (Anti-Double-Stamp)"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "test@stamp.com"
  git config user.name "Stamper"

  echo "content" > file.txt
  git add . && git commit -m "stable commit" -q

  # First stamp
  git-stamp-commit >/dev/null
  local first_stamp=$(git log -1 --pretty=%B | grep "^uuid-stamp:")

  # Second stamp attempt
  git-stamp-commit >/dev/null

  local final_msg=$(git log -1 --pretty=%B)
  local stamp_count=$(echo "$final_msg" | grep -c "^uuid-stamp:")

  rm -rf "$tmp_repo"

  if [[ $stamp_count -eq 1 ]]; then
    echo "✅ SUCCESS: Idempotency preserved (only 1 stamp exists)."
    return 0
  else
    echo "❌ ERROR: Multiple stamps detected! Idempotency failed."
    return 1
  fi
}
