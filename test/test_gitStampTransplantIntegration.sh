#!/usr/bin/env bash

test_gitStampTransplantIntegration() {
  echo "🧪 Testing Stamp Traceability through Path Transplant"
  local tmp_root=$(mktemp -d)
  local monorepo="$tmp_root/monorepo"
  local target_repo="$tmp_root/service_alpha"

  # 1. Setup Monorepo and create a commit
  mkdir -p "$monorepo/libs/core" && cd "$monorepo" && git init -q
  git config user.email "dev@stack.com" && git config user.name "Architect"

  echo "shared logic" >libs/core/logic.sh
  git add . && git commit -m "feat: add core logic" -q

  # 2. Add the UUID stamp
  git-stamp-commit >/dev/null
  local original_uuid=$(git-stamp-info | grep "Stamp:" | awk '{print $2}')

  echo "🔖 Created UUID: $original_uuid"

  # 3. Simulate a split (Manual transplant to a new repo)
  # This creates a totally different history/hash, but keeps the message
  mkdir -p "$target_repo" && cd "$target_repo" && git init -q
  git config user.email "dev@stack.com" && git config user.name "Architect"

  # We create a commit with a different tree but the SAME uuid-stamp
  echo "logic ported" >ported_logic.sh
  git add . && git commit -m "port: core logic (uuid-stamp: $original_uuid)" -q

  local hash_mono=$(git -C "$monorepo" rev-parse HEAD)
  local hash_target=$(git -C "$target_repo" rev-parse HEAD)

  echo "📍 Monorepo Hash: $hash_mono"
  echo "📍 Target Hash:   $hash_target"

  # 4. Use the tool to find the identity across both repos
  echo "🏃 Running Discovery across $tmp_root..."
  local matches
  matches=$(git-find-by-stamp "$original_uuid" "$tmp_root" --quiet)

  local count=$(echo "$matches" | wc -l)

  rm -rf "$tmp_root"

  if [[ $count -ge 2 ]]; then
    echo "✅ SUCCESS: Found identical stamp in 2 different repositories."
    return 0
  else
    echo "❌ FAILURE: Discovery tool could not link the transplanted commits."
    return 1
  fi
}
