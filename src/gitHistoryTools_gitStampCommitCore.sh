#!/usr/bin/env bash

_git_stamp_commit_core() {
  local reverse=${1:-0}
  local debug="${DEBUG:-}"
  local debugf="${DEBUGF:-}"

  # Helper for raw object inspection
  _dump_commit_raw() {
    [[ -n $debugf ]] && {
      echo "--- RAW COMMIT OBJECT ($1) ---"
      git cat-file -p HEAD
      echo "------------------------------"
    }
  }

  if [[ $reverse -eq 1 ]]; then
    [[ -n $debug ]] && echo "🔍 [DEBUG] Attempting to reverse stamp on HEAD..."
    _dump_commit_raw "BEFORE_REVERSE"

    local msg=$(git log -1 --pretty=%B)
    if echo "$msg" | grep -q "^uuid-stamp:"; then
      # Capture original dates to attempt parity (even if split logic won't use it)
      local adate=$(git log -1 --pretty=%ad)
      local cdate=$(git log -1 --pretty=%cd)

      [[ -n $debug ]] && echo "📝 [DEBUG] Found stamp. Stripping..."

      # Remove the stamp line and clean trailing whitespace
      local clean_msg=$(echo "$msg" | sed '/^uuid-stamp:/d' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

      GIT_AUTHOR_DATE="$adate" GIT_COMMITTER_DATE="$cdate" \
        git commit --amend --message="$(printf "%s\n" "$clean_msg")" --no-edit --quiet

      [[ -n $debug ]] && echo "✅ [DEBUG] Reverse amend complete."
      _dump_commit_raw "AFTER_REVERSE"
    fi
    return 0
  fi

  # --- Stamping Mode ---
  if git log -1 --pretty=%B | grep -q "^uuid-stamp:"; then
    [[ -n $debug ]] && echo "⚠️ [DEBUG] Commit already stamped. Skipping."
    return 0
  fi

  local new_uuid=""
  if [[ -f /proc/sys/kernel/random/uuid ]]; then
    new_uuid=$(cat /proc/sys/kernel/random/uuid)
  elif command -v uuidgen >/dev/null 2>&1; then
    new_uuid=$(uuidgen)
  fi

  [[ -n $debug ]] && echo "🎫 [DEBUG] Generated UUID: $new_uuid"
  _dump_commit_raw "BEFORE_STAMP"

  local current_msg=$(git log -1 --pretty=%B | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')
  local stamped_msg=$(printf "%s\n\nuuid-stamp: %s\n" "$current_msg" "$new_uuid")

  git commit --amend --message="$stamped_msg" --no-edit --quiet

  [[ -n $debug ]] && echo "✅ [DEBUG] Stamp applied: $new_uuid"
  _dump_commit_raw "AFTER_STAMP"
}

export -f _git_stamp_commit_core
