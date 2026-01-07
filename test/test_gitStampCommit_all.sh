#!/usr/bin/env bash
test_gitStampCommit_all() {
  export LC_NUMERIC=C
  local test_functions=(
    "test_gitStampCommit_single"
    "test_gitStampCommit_bulk"
    "test_gitStampBulkReverse"
    "test_gitStampRecent_range"
    "test_gitCherryPickStamp_preservation"
    "test_gitStampStressParity"
    "test_gitStamp_reverse_single"
    "test_gitStampStressParity"
  )
  local ignored_tests=()
  bashTestRunner test_functions ignored_tests
}
