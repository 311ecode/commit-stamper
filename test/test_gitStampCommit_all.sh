#!/usr/bin/env bash
test_gitStampCommit_all() {
  export LC_NUMERIC=C
  local test_functions=(
    "test_gitStampCommit_single"
    "test_gitStampCommit_bulk"
    "test_gitFindByStamp"
    "test_gitStampCommit_idempotency"
    "test_gitCherryPickStamp_preservation"
    "test_gitStampRecent_range"
  )
  local ignored_tests=()
  bashTestRunner test_functions ignored_tests
}