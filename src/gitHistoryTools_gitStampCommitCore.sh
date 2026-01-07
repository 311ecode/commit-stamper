#!/usr/bin/env bash

_git_stamp_commit_core() {
    local reverse=${1:-0}
    
    if [[ $reverse -eq 1 ]]; then
        local msg
        msg=$(git log -1 --pretty=%B)
        if echo "$msg" | grep -q "^uuid-stamp:"; then
            # Strip the stamp and any trailing whitespace
            local clean_msg
            clean_msg=$(echo "$msg" | sed '/^uuid-stamp:/d' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')
            git commit --amend --message="$clean_msg" --no-edit --quiet
            return 0
        fi
        return 0
    fi

    # 1. Check for existing stamp
    if git log -1 --pretty=%B | grep -q "^uuid-stamp:"; then
        echo "⚠️  Commit already has a uuid-stamp."
        return 0
    fi

    # 2. Generate UUID
    local new_uuid=""
    if [[ -f /proc/sys/kernel/random/uuid ]]; then
        new_uuid=$(cat /proc/sys/kernel/random/uuid)
    elif command -v uuidgen >/dev/null 2>&1; then
        new_uuid=$(uuidgen)
    else
        echo "❌ ERROR: Could not generate UUID. Install uuidgen." >&2
        return 1
    fi

    # 3. Amend the commit
    # We append two newlines to ensure separation from the body
    local current_msg
    current_msg=$(git log -1 --pretty=%B)
    local stamped_msg=$(printf "%s\n\nuuid-stamp: %s\n" "$current_msg" "$new_uuid")
    
    git commit --amend --message="$stamped_msg" --no-edit --quiet
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Stamped HEAD with: $new_uuid"
    else
        return 1
    fi
}

export -f _git_stamp_commit_core
