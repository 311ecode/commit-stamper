#!/usr/bin/env bash

_git_stamp_all_commits_core() {
  local reverse=0
  [[ "$1" == "1" || "$1" == "--reverse" ]] && reverse=1

  if ! command -v git-filter-repo >/dev/null 2>&1; then
      echo "❌ ERROR: git-filter-repo is required for bulk operations."
      echo "   Install it via: pip install --user git-filter-repo"
      return 1
  fi

  if [[ $reverse -eq 1 ]]; then
    echo "🚀 Bulk stripping uuid-stamps from all commits..."
    git filter-repo --message-callback '
import re

# First normalize: remove trailing whitespace/newlines
msg = message.rstrip()

# Remove the exact stamp pattern we typically add: double newline + stamp + possible final newline
msg = re.sub(rb"\n\nuuid-stamp: [0-9a-f-]{36}\n?$", b"", msg)

# Clean up any leftover extra newlines at end
return msg.rstrip() + b"\n" if msg else b""
' --force
  else
    echo "🚀 Bulk stamping all commits with unique UUIDs..."
    git filter-repo --message-callback '
import uuid

if b"uuid-stamp:" not in message:
    new_uuid = str(uuid.uuid4())
    stamp_line = b"\n\nuuid-stamp: " + new_uuid.encode("ascii") + b"\n"
    # Append to message after stripping trailing whitespace
    return message.rstrip() + stamp_line
return message
' --force
  fi
}

export -f _git_stamp_all_commits_core