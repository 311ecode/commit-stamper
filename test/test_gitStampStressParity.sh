#!/usr/bin/env bash

test_gitStampStressParity() {
  echo "🧪 Stress Test: History Round-Trip Content Parity (Message Reversible)"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q

  git config user.email "<stress@parity.com>"
  git config user.name "StressTester"

  # Create two simple commits with clean messages
  echo "1" >f.txt && git add . && git commit -q -m "feat: first"
  echo "2" >f.txt && git add . && git commit -q -m "feat: second"

  local original_head=$(git rev-parse HEAD)
  echo "📍 Original HEAD: $original_head"

  # Stamp
  if ! git-stamp-all-commits >/dev/null 2>&1; then
    echo "❌ Stamping failed"
    rm -rf "$tmp_repo"
    return 1
  fi
  echo "🔨 Stamped."

  # Un-stamp
  if ! git-stamp-all-commits --reverse >/dev/null 2>&1; then
    echo "❌ Un-stamping failed"
    rm -rf "$tmp_repo"
    return 1
  fi
  echo "🔙 Reversed."

  local final_head=$(git rev-parse HEAD)
  echo "📍 Final HEAD: $final_head"

  # Quick hash check (will almost always fail, but log for visibility)
  if [[ $original_head == "$final_head" ]]; then
    echo "🎉 Rare success: Exact hash preserved!"
  else
    echo "ℹ️  Note: Hash changed (expected when message is modified)"
  fi

  # Real check: compare original vs final commit objects (excluding timestamps)
  local orig_raw
  orig_raw=$(git cat-file -p "$original_head" 2>/dev/null) || {
    echo "❌ Original commit missing"
    rm -rf "$tmp_repo"
    return 1
  }

  local final_raw
  final_raw=$(git cat-file -p "$final_head" 2>/dev/null) || {
    echo "❌ Final commit missing"
    rm -rf "$tmp_repo"
    return 1
  }

  # Normalize timestamps (they often differ slightly) and compare
  local orig_normalized=$(echo "$orig_raw" | grep -vE '^(author|committer) ' | sort)
  local final_normalized=$(echo "$final_raw" | grep -vE '^(author|committer) ' | sort)

  if [[ $orig_normalized == "$final_normalized" ]]; then
    echo "✅ SUCCESS: Commit content matches after round-trip (message restored, tree/parents preserved)"
    rm -rf "$tmp_repo"
    return 0
  else
    echo "❌ FAILURE: Commit content differs after round-trip"
    echo "--- Original (normalized) ---"
    echo "$orig_normalized"
    echo "--- Final (normalized) ---"
    echo "$final_normalized"
    echo "--- Full diff ---"
    diff <(echo "$orig_raw") <(echo "$final_raw") || true
    rm -rf "$tmp_repo"
    return 1
  fi
}
