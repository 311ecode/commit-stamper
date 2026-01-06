#!/usr/bin/env bash
git-stamp-all-commits() {
  # This uses git-filter-repo for high-speed bulk stamping
  # It applies a unique UUID to every commit that doesn't have one
  
  if ! command -v git-filter-repo &>/dev/null; then
    echo "ERROR: git-filter-repo is required for bulk stamping." >&2
    return 1
  fi

  echo "🚀 Bulk stamping all commits in history..."

  # We use a python snippet within filter-repo to generate a new UUID for every message
  git filter-repo --message-callback '
    import uuid
    import re
    if b"uuid-stamp:" not in message:
        new_uuid = str(uuid.uuid4()).encode("utf-8")
        return message.rstrip() + b"\n\nuuid-stamp: " + new_uuid + b"\n"
    return message
  ' --force
}