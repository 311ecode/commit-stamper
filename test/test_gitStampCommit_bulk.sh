#!/usr/bin/env bash

test_gitStampCommit_bulk() {
    echo "🧪 Testing git-stamp-all-commits (Bulk)"

    if [[ -n "$DEBUG" ]]; then
        set -x
    fi

    local tmp_root=$(mktemp -d 2>/dev/null || mktemp -d -t 'gitstamp-test')
    trap "rm -rf '$tmp_root'" EXIT

    local repo="$tmp_root/bulk-test-repo"
    mkdir -p "$repo"
    cd "$repo" || { echo "❌ Cannot cd to $repo"; return 1; }

    git init -q
    git config user.name  "BulkTester"
    git config user.email "bulk@test.invalid"

    # Create clean history
    for i in {1..4}; do
        echo "line $i" > "file$i.txt"
        git add -A
        git commit -q -m "commit $i"
    done

    echo "→ Repository setup complete. HEAD = $(git rev-parse --short HEAD)"

    # ── Dependency checks ────────────────────────────────────────
    if ! command -v git-filter-repo >/dev/null 2>&1; then
        echo "❌ FATAL: git-filter-repo not found in PATH"
        echo "   Try: pip install --user git-filter-repo  or system package"
        return 1
    fi

    if ! python3 -c "import uuid" 2>/dev/null; then
        echo "❌ FATAL: Python uuid module not available"
        echo "   Current python: $(python3 --version 2>/dev/null || echo 'not found')"
        return 1
    fi

    echo "→ Dependencies OK: git-filter-repo + python uuid present"

    # Force clean state
    git reset --hard HEAD >/dev/null 2>&1
    git status --porcelain | grep -q . && {
        echo "❌ Repository is dirty before stamping!"
        git status --short
        return 1
    }

    # Run the actual stamping
    if ! _git_stamp_all_commits_core 0 >/dev/null 2>stamp.err; then
        echo "❌ ERROR: _git_stamp_all_commits_core failed (exit code $?)"
        echo "─── git-filter-repo stderr output ───────"
        cat stamp.err
        echo "─────────────────────────────────────────"
        echo "Current directory: $(pwd)"
        echo "git status:"
        git status --short
        return 1
    fi

    # Critical: git-filter-repo often changes cwd - recover
    cd "$repo" 2>/dev/null || {
        echo "❌ FATAL: Cannot return to $repo after git-filter-repo"
        return 1
    }

    local stamp_count=$(git log --pretty=%B | grep -c "^uuid-stamp:" || true)
    local unique_count=$(git log --pretty=%B | grep "^uuid-stamp:" | sort -u | wc -l | tr -d '[:space:]')

    echo "→ Found $stamp_count stamp lines, $unique_count unique"

    if [[ $stamp_count -eq 4 && $unique_count -eq 4 ]]; then
        echo "✅ SUCCESS: All 4 commits properly stamped with unique UUIDs"
        return 0
    else
        echo "❌ FAILURE: Stamp count mismatch"
        echo "   Expected: 4 stamps / 4 unique"
        echo "   Got:      $stamp_count / $unique_count"
        git log --pretty="format:%h  %s%n%B" | grep -A1 "uuid-stamp"
        return 1
    fi
}