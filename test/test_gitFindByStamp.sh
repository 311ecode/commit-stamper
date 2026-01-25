#!/usr/bin/env bash

test_gitFindByStamp() {
  echo "🧪 Testing git-find-by-stamp (Discovery)"
  local tmp_base=$(mktemp -d)

  # 1. Setup Repo A and stamp a commit
  mkdir -p "$tmp_base/repoA" && cd "$tmp_base/repoA" && git init -q
  git config user.email "t@test.com" && git config user.name "Tester"
  echo "data" >a.txt && git add . && git commit -m "original work" -q

  git-stamp-commit >/dev/null
  local stamp=$(git log -1 --pretty=%B | grep "uuid-stamp:" | cut -d' ' -f2)

  # 2. Setup Repo B (Unrelated)
  mkdir -p "$tmp_base/repoB" && cd "$tmp_base/repoB" && git init -q
  echo "other" >b.txt && git add . && git commit -m "unrelated work" -q

  # 3. Execute Search
  local output
  output=$(git-find-by-stamp "$stamp" "$tmp_base")

  rm -rf "$tmp_base"

  if echo "$output" | grep -q "repoA" && echo "$output" | grep -q "original work"; then
    echo "✅ SUCCESS: Found the stamped commit in repoA."
    return 0
  else
    echo "❌ ERROR: Could not find the stamped commit."
    return 1
  fi
}
