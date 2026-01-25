#!/usr/bin/env bash

test_gitFindIdentity() {
  echo "🧪 Testing Identity Discovery (Survival across Split/Move)"
  local tmp_base=$(mktemp -d)

  # 1. Setup Original Repo
  local repo_a="$tmp_base/monorepo"
  mkdir -p "$repo_a" && cd "$repo_a" && git init -q
  git config user.email "dev@dev.com" && git config user.name "Developer"

  echo "important code" >feature.sh
  git add . && git commit -m "feat: original work" -q

  # 2. Stamp it
  git-stamp-commit >/dev/null
  local uuid=$(git log -1 --pretty=%B | grep "uuid-stamp:" | cut -d' ' -f2)
  echo "🎫 Generated UUID: $uuid"

  # 3. Simulate a "Split" or "Transplant"
  # (Manual creation of a new repo with different hash but same UUID)
  local repo_b="$tmp_base/polyrepo"
  mkdir -p "$repo_b" && cd "$repo_b" && git init -q
  git config user.email "dev@dev.com" && git config user.name "Developer"

  # Different content/context (Hash will be different)
  echo "moved code" >transplanted_feature.sh
  git add . && git commit -m "feat: transplanted work (uuid-stamp: $uuid)" -q

  local hash_a=$(git -C "$repo_a" rev-parse HEAD)
  local hash_b=$(git -C "$repo_b" rev-parse HEAD)

  echo "📍 Hash A: $hash_a"
  echo "📍 Hash B: $hash_b"

  # 4. Search
  echo "🏃 Running Discovery..."
  local results=$(git-find-by-stamp "$uuid" "$tmp_base")
  local match_count=$(echo "$results" | grep -c "[MATCH FOUND]")

  rm -rf "$tmp_base"

  if [[ $match_count -ge 2 ]]; then
    echo "✅ SUCCESS: Found identity in both repos despite different hashes."
    return 0
  else
    echo "❌ FAILURE: Discovery failed to link the split commits."
    return 1
  fi
}
