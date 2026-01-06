#!/usr/bin/env bash
git-stamp-commit() {
  # 1. Generate UUID (Linux specific)
  local uuid
  uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null)
  
  if [[ -z $uuid ]]; then
    echo "ERROR: Could not generate UUID. Ensure /proc/sys/kernel/random/uuid exists or install uuidgen." >&2
    return 1
  fi

  # 2. Check if already stamped
  if git log -1 --pretty=%B | grep -q "^uuid-stamp:"; then
    echo "⚠️  Commit already has a uuid-stamp." >&2
    return 0
  fi

  # 3. Amend the commit message
  # --no-edit preserves the original metadata (author, date)
  git commit --amend -m "$(git log -1 --pretty=%B)$(printf "\n\nuuid-stamp: %s" "$uuid")" --no-edit --quiet
  echo "✅ Stamped HEAD with: $uuid"
}