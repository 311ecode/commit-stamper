#!/usr/bin/env bash
git-stamp-recent() {
  if ! declare -f _git_stamp_recent_core >/dev/null; then
    source "$(dirname "${BASH_SOURCE[0]}")/gitHistoryTools_gitStampRecent.sh"
  fi
  _git_stamp_recent_core "$@"
}
