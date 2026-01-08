#!/usr/bin/env bash

git-find-by-stamp() {
    local stamp="$1"
    local root="${2:-.}"
    local quiet=0
    [[ "$3" == "--quiet" ]] && quiet=1

    [[ -z $stamp ]] && { echo "Usage: git-find-by-stamp <uuid> [root_dir]" >&2; return 1; }
    
    # Normalize: strip prefix if user pasted the whole line
    stamp=$(echo "$stamp" | sed 's/^uuid-stamp: //')

    [[ $quiet -eq 0 ]] && echo "🔍 Searching for UUID Identity: $stamp ..." >&2

    # Find all directories containing .git folders
    find "$root" -name ".git" -type d 2>/dev/null | while read -r gitdir; do
        local repo_dir=$(dirname "$gitdir")
        
        # Check all branches and tags for the stamp
        # We search specifically for the uuid-stamp line to avoid false positives
        local match
        match=$(git -C "$repo_dir" log --all --grep="uuid-stamp: $stamp" --format="%H|%an|%ar|%s" -n 1 2>/dev/null)
        
        if [[ -n $match ]]; then
            IFS='|' read -r hash author date subject <<< "$match"
            
            if [[ $quiet -eq 1 ]]; then
                echo "$repo_dir:$hash"
            else
                echo -e "\033[38;5;46m[MATCH]\033[0m $repo_dir"
                echo -e "        🆔 Hash:   $hash"
                echo -e "        👤 Author: $author"
                echo -e "        📅 Date:   $date"
                echo -e "        💬 Msg:    $subject"
                echo ""
            fi
        fi
    done
}
