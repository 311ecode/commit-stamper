#!/usr/bin/env bash

test_gitStampUniversalParity() {
  echo "🧪 Universal Stress Test: Hash Parity for All Tools"
  local tmp_repo=$(mktemp -d)
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "parity@master.com"
  git config user.name "ParityMaster"

  # --- SETUP: Create 3 commits ---
  echo "1" > f.txt && git add . && git commit -m "first" -q
  echo "2" > f.txt && git add . && git commit -m "second" -q
  echo "3" > f.txt && git add . && git commit -m "third" -q
  
  local original_head=$(git rev-parse HEAD)
  echo "📍 Original HEAD: $original_head"

  # --- PHASE 1: Single Commit Tool ---
  echo "🏃 Testing git-stamp-commit..."
  git-stamp-commit >/dev/null
  git-stamp-commit --reverse >/dev/null
  [[ $(git rev-parse HEAD) != "$original_head" ]] && { echo "❌ Failed: Single tool parity"; return 1; }

  # --- PHASE 2: Recent Tool ---
  echo "🏃 Testing git-stamp-recent..."
  git-stamp-recent >/dev/null 2>&1
  git-stamp-recent --reverse >/dev/null 2>&1
  [[ $(git rev-parse HEAD) != "$original_head" ]] && { echo "❌ Failed: Recent tool parity"; return 1; }

  # --- PHASE 3: Bulk Tool ---
  echo "🏃 Testing git-stamp-all-commits..."
  git-stamp-all-commits >/dev/null 2>&1
  git-stamp-all-commits --reverse >/dev/null 2>&1
  
  local final_head=$(git rev-parse HEAD)
  echo "📍 Final HEAD:    $final_head"

  if [[ "$original_head" == "$final_head" ]]; then
    echo "✅ SUCCESS: All tools passed perfect hash parity."
    rm -rf "$tmp_repo"
    return 0
  else
    echo "❌ ERROR: Final Hash Mismatch."
    # Debug: show exactly which field in the raw object changed
    diff <(git cat-file -p "$original_head") <(git cat-file -p "$final_head")
    rm -rf "$tmp_repo"
    return 1
  fi
}
