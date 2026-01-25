#!/usr/bin/env bash

git-stamp-commit() {
  # Ensure core is loaded
  if ! declare -f _git_stamp_commit_core >/dev/null; then
    source "$(dirname "${BASH_SOURCE[0]}")/gitHistoryTools_gitStampCommitCore.sh"
  fi

  local reverse=0
  [[ $1 == "--reverse" ]] && reverse=1
  _git_stamp_commit_core "$reverse"
}
