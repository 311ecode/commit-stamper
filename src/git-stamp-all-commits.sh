#!/usr/bin/env bash
git-stamp-all-commits() {
  if ! declare -f _git_stamp_all_commits_core >/dev/null; then
    source "$(dirname "${BASH_SOURCE[0]}")/gitHistoryTools_gitStampCommit.sh"
  fi
  _git_stamp_all_commits_core "$@"
}
