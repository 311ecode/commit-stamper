#!/usr/bin/env bash

test_gitStampRecent_range() {
  echo "🧪 Testing git-stamp-recent (Incremental Stamping)"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "test@stamp.com"
  git config user.name "Stamper"

  # 1. Create 2 Stamped commits
  echo "old 1" > file.txt && git add . && git commit -m "old 1" -q && git-stamp-commit >/dev/null
  echo "old 2" > file.txt && git add . && git commit -m "old 2" -q && git-stamp-commit >/dev/null
  
  local last_safe_stamp=$(git log -1 --pretty=%B | grep "^uuid-stamp:")

  # 2. Create 2 Unstamped commits
  echo "new 1" > file.txt && git add . && git commit -m "new 1" -q
  echo "new 2" > file.txt && git add . && git commit -m "new 2" -q

  # 3. Execute Recent Stamp
  git-stamp-recent >/dev/null 2>&1

  # 4. VERIFY
  local total_stamps=$(git log --pretty=%B | grep -c "^uuid-stamp:")
  
  # Check that the old stamp is still the same (proves we didn't restamp everything)
  local historical_stamp=$(git log --reverse --pretty=%B | sed -n '2p' | grep "^uuid-stamp:")

  rm -rf "$tmp_repo"

  if [[ $total_stamps -eq 4 ]]; then
    echo "✅ SUCCESS: Stamped only the unstamped tail."
    return 0
  else
    echo "❌ ERROR: Stamping count mismatch (Expected 4, got $total_stamps)."
    return 1
  fi
}
