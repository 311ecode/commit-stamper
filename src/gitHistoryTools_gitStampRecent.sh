#!/usr/bin/env bash

git-stamp-recent() {
  local current_ref="HEAD"
  local commits_to_stamp=()

  echo "🔍 Scanning for unstamped recent commits..."

  # 1. Identify the range of unstamped commits
  while true; do
    local msg
    msg=$(git log -1 --pretty=%B "$current_ref" 2>/dev/null)
    
    # Stop if we hit the beginning of the repo or an invalid ref
    [[ -z $msg ]] && break

    # Stop if we hit a commit that is already stamped
    if echo "$msg" | grep -q "^uuid-stamp:"; then
      [[ -n ${DEBUG:-} ]] && echo "DEBUG: Found existing stamp at $(git rev-parse --short "$current_ref")" >&2
      break
    fi

    # Add this hash to our "to-do" list
    commits_to_stamp+=($(git rev-parse "$current_ref"))
    
    # Move to the parent
    current_ref="$current_ref^"
  done

  local count=${#commits_to_stamp[@]}
  if [[ $count -eq 0 ]]; then
    echo "✅ All recent commits are already stamped."
    return 0
  fi

  echo "📝 Found $count unstamped commits. Stamping now..."

  # 2. Rebase/Rewrite only this specific range
  # We use filter-repo with a commit-filter to be surgery-precise
  local first_unstamped=${commits_to_stamp[-1]}
  
  # We use a temporary file to pass the list of hashes to the python filter
  # to ensure we only touch the specific 'tail' we found.
  git filter-repo --message-callback "
import uuid
if b'uuid-stamp:' not in message:
    return message.rstrip() + b'\n\nuuid-stamp: ' + str(uuid.uuid4()).encode('utf-8') + b'\n'
return message
" --refs "$first_unstamped^..HEAD" --force

  echo "✅ Successfully stamped $count commits."
}
