#!/usr/bin/env bash

test_gitStamp_reverse_single() {
  echo "🧪 Testing git-stamp-commit --reverse"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "test@stamp.com"
  git config user.name "Stamper"

  echo "content" >file.txt && git add . && git commit -m "work" -q
  git-stamp-commit >/dev/null

  # Strip it
  git-stamp-commit --reverse >/dev/null

  local msg=$(git log -1 --pretty=%B)
  rm -rf "$tmp_repo"

  if echo "$msg" | grep -q "uuid-stamp:"; then
    echo "❌ ERROR: Stamp was not removed."
    return 1
  else
    echo "✅ SUCCESS: Stamp removed cleanly."
    return 0
  fi
}

test_gitStamp_reverse_all() {
  export LC_NUMERIC=C
  local test_functions=(
    "test_gitStamp_reverse_single"
  )
  local ignored_tests=()
  bashTestRunner test_functions ignored_tests
}
