#!/usr/bin/env bash

git-find-by-stamp() {
  local stamp="$1"
  local search_root="${2:-.}"

  if [[ -z $stamp ]]; then
    echo "Usage: git-find-by-stamp <uuid> [search_root]" >&2
    return 1
  fi

  # Clean input: remove prefix if the user pasted the whole line
  stamp=$(echo "$stamp" | sed 's/^uuid-stamp: //')

  echo "🔍 Searching for uuid-stamp: $stamp in $search_root..."

  # Find all git repos under search_root
  find "$search_root" -type d -name ".git" 2>/dev/null | while read -r git_dir; do
    local repo_dir
    repo_dir=$(dirname "$git_dir")
    
    # Use -F (fixed string) for speed and exact matching
    local found_hash
    found_hash=$(git -C "$repo_dir" log --all --grep="uuid-stamp: $stamp" --format="%H" -n 1 2>/dev/null)
    
    if [[ -n $found_hash ]]; then
      echo -e "\033[38;5;46m[MATCH]\033[0m Repo: $repo_dir"
      echo -e "        Hash: $found_hash"
      git -C "$repo_dir" log -1 --pretty=format:"        Msg:  %s (%ar)%n" "$found_hash"
    fi
  done
}
