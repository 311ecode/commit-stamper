#!/usr/bin/env bash

test_gitStampUniversalParity() {
  echo "🧪 Universal Test: Identity & Content Stability (No Hash Check)"
  local start_dir="$PWD"
  local tmp_repo=$(mktemp -d)

  # 1. Setup
  cd "$tmp_repo" || return 1
  git init -q
  git config user.email "identity@test.com" && git config user.name "IdentityBot"

  # 2. Create History (1 -> 2 -> 3)
  echo "content 1" >f1.txt && git add . && git commit -m "feat: first" -q
  echo "content 2" >f2.txt && git add . && git commit -m "feat: second" -q
  echo "content 3" >f3.txt && git add . && git commit -m "feat: third" -q

  local original_tree=$(git rev-parse HEAD^{tree})

  # 3. Run the Tool
  echo "🏃 Running git-stamp-recent..."
  if ! git-stamp-recent >/dev/null; then
    echo "❌ Tool execution failed."
    cd "$start_dir" && rm -rf "$tmp_repo"
    return 1
  fi

  # 4. Verify Content (Did we lose commits?)
  #
  local final_tree=$(git rev-parse HEAD^{tree})

  if [[ $original_tree != "$final_tree" ]]; then
    echo "❌ FATAL: Content changed! (Data Loss Detected)"
    echo "Expected Tree: $original_tree"
    echo "Actual Tree:   $final_tree"
    git ls-tree -r HEAD
    cd "$start_dir" && rm -rf "$tmp_repo"
    return 1
  fi
  echo "✅ Content preserved (Tree hash matches)."

  # 5. Verify Identity (Do we have stamps?)
  local stamp_count=$(git log --pretty=%B | grep -c "^uuid-stamp:")
  if [[ $stamp_count -ne 3 ]]; then
    echo "❌ Failed to stamp all commits. Found $stamp_count/3."
    cd "$start_dir" && rm -rf "$tmp_repo"
    return 1
  fi
  echo "✅ Identity established (3/3 stamps)."

  # 6. Verify Discovery
  local head_uuid=$(git log -1 --pretty=%B | grep "uuid-stamp:" | cut -d' ' -f2)
  local found=$(git-find-by-stamp "$head_uuid" "$tmp_repo" --quiet)

  if [[ -z $found ]]; then
    echo "❌ Discovery failed."
    cd "$start_dir" && rm -rf "$tmp_repo"
    return 1
  fi
  echo "✅ Discovery verified."

  # Cleanup safely
  cd "$start_dir"
  rm -rf "$tmp_repo"
  return 0
}
