#!/usr/bin/env bash

test_gitCherryPickStamp_preservation() {
  echo "🧪 Testing Cherry-Pick Stamp Preservation"
  local tmp_base=$(mktemp -d)
  
  # Setup Source Repo
  mkdir -p "$tmp_base/source" && cd "$tmp_base/source" && git init -q
  git config user.email "t@t.com" && git config user.name "Tester"
  echo "content" > file.txt && git add . && git commit -m "stamped work" -q
  git-stamp-commit > /dev/null
  local original_stamp=$(git log -1 --pretty=%B | grep "^uuid-stamp:")
  local commit_hash=$(git rev-parse HEAD)

  # Setup Target Repo
  mkdir -p "$tmp_base/target" && cd "$tmp_base/target" && git init -q
  git config user.email "t@t.com" && git config user.name "Tester"
  git remote add origin "$tmp_base/source"
  git fetch origin --quiet

  # Execute Cherry Pick
  git-cherry-pick-stamp "$commit_hash" > /dev/null

  local new_stamp=$(git log -1 --pretty=%B | grep "^uuid-stamp:")
  
  rm -rf "$tmp_base"

  if [[ "$original_stamp" == "$new_stamp" ]]; then
    echo "✅ SUCCESS: Stamp preserved during cherry-pick."
    return 0
  else
    echo "❌ ERROR: Stamp changed or lost during cherry-pick."
    return 1
  fi
}
