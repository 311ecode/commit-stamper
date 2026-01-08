#!/usr/bin/env bash

git-stamp-info() {
  local commit_ref="${1:-HEAD}"
  local msg
  msg=$(git log -1 --pretty=%B "$commit_ref" 2>/dev/null)
  
  if [[ -z "$msg" ]]; then
    echo "❌ ERROR: Invalid commit reference '$commit_ref'" >&2
    return 1
  fi

  local stamp
  stamp=$(echo "$msg" | grep "^uuid-stamp:" | cut -d' ' -f2)

  if [[ -n "$stamp" ]]; then
    echo "Commit: $(git rev-parse "$commit_ref")"
    echo "Stamp:  $stamp"
    return 0
  else
    echo "No uuid-stamp found for $commit_ref"
    return 1
  fi
}
