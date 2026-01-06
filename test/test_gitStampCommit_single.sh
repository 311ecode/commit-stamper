#!/usr/bin/env bash
test_gitStampCommit_single() {
  echo "🧪 Testing git-stamp-commit (Single)"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "test@stamp.com"
  git config user.name "Stamper"

  echo "content" > file.txt
  git add . && git commit -m "initial commit" -q

  git-stamp-commit

  local msg
  msg=$(git log -1 --pretty=%B)
  rm -rf "$tmp_repo"

  if echo "$msg" | grep -q "^uuid-stamp: [0-9a-f-]\+"; then
    echo "✅ SUCCESS: Single commit stamped correctly."
    return 0
  else
    echo "❌ ERROR: uuid-stamp missing or malformed."
    return 1
  fi
}