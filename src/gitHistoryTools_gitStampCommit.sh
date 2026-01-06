#!/usr/bin/env bash

# gitHistoryTools_gitStampCommit.sh
# Aggregator and high-level helpers for the commit stamping suite.

git-stamp-info() {
  local hash="${1:-HEAD}"
  local msg
  msg=$(git log -1 --pretty=%B "$hash" 2>/dev/null)
  
  if [[ -z $msg ]]; then
    echo "ERROR: Invalid commit hash: $hash" >&2
    return 1
  fi

  local stamp
  stamp=$(echo "$msg" | grep "^uuid-stamp:" | cut -d' ' -f2)
  
  if [[ -n $stamp ]]; then
    echo "Commit: $(git rev-parse --short "$hash")"
    echo "Stamp:  $stamp"
  else
    echo "No uuid-stamp found for commit $hash"
    return 1
  fi
}

git-stamp-verify-idempotency() {
  echo "🔍 Checking for duplicate stamps in history..."
  local duplicates
  duplicates=$(git log --all --pretty=%B | grep "^uuid-stamp:" | sort | uniq -d)
  
  if [[ -n $duplicates ]]; then
    echo "⚠️  WARNING: Duplicate UUID stamps detected:"
    echo "$duplicates"
    return 1
  else
    echo "✅ All stamps are unique."
    return 0
  fi
}
