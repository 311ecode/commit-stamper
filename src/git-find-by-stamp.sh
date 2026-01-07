#!/usr/bin/env bash
git-find-by-stamp() {
  local stamp="$1"
  local root="${2:-.}"
  [[ -z $stamp ]] && return 1
  stamp=$(echo "$stamp" | sed 's/^uuid-stamp: //')
  find "$root" -type d -name ".git" | while read -r g; do
    local r=$(dirname "$g")
    local h=$(git -C "$r" log --all --grep="uuid-stamp: $stamp" --format="%H" -n 1 2>/dev/null)
    [[ -n $h ]] && echo -e "\033[38;5;46m[MATCH]\033[0m $r -> $h"
  done
}
