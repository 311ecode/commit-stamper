#!/usr/bin/env bash
test_gitStampCommit_bulk() {
  echo "🧪 Testing git-stamp-all-commits (Bulk)"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "test@stamp.com"
  git config user.name "Stamper"

  for i in {1..3}; do
    echo "$i" > "file$i.txt"
    git add . && git commit -m "commit $i" -q
  done

  git-stamp-all-commits >/dev/null 2>&1

  local stamp_count
  stamp_count=$(git log --pretty=%B | grep -c "^uuid-stamp:")
  
  local unique_stamps
  unique_stamps=$(git log --pretty=%B | grep "^uuid-stamp:" | sort -u | wc -l)

  rm -rf "$tmp_repo"

  if [[ $stamp_count -eq 3 && $unique_stamps -eq 3 ]]; then
    echo "✅ SUCCESS: All commits stamped with unique UUIDs."
    return 0
  else
    echo "❌ ERROR: Bulk stamping failed (Found $stamp_count stamps, $unique_stamps unique)."
    return 1
  fi
}