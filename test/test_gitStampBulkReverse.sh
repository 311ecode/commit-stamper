#!/usr/bin/env bash
test_gitStampBulkReverse() {
  echo "🧪 Testing git-stamp-all-commits --reverse"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "test@stamp.com" && git config user.name "Tester"

  for i in {1..3}; do
    echo "$i" >"f$i.txt" && git add . && git commit -m "commit $i" -q
  done

  # Stamp all
  git-stamp-all-commits >/dev/null 2>&1

  # Strip all
  git-stamp-all-commits --reverse >/dev/null 2>&1

  local remaining_stamps
  remaining_stamps=$(git log --pretty=%B | grep -c "^uuid-stamp:")

  rm -rf "$tmp_repo"

  if [[ $remaining_stamps -eq 0 ]]; then
    echo "✅ SUCCESS: All stamps stripped from history."
    return 0
  else
    echo "❌ ERROR: Some stamps remain ($remaining_stamps found)."
    return 1
  fi
}
