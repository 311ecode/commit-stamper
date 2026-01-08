#!/usr/bin/env bash

test_gitStampSuite() {
  echo "🚀 Initializing Git Stamp Universal Test Suite"
  
  local test_functions=(
    "test_gitStampCommit_single"
    "test_gitStampCommit_bulk"
    "test_gitStampBulkReverse"
    "test_gitStampRecent_range"
    "test_gitCherryPickStamp_preservation"
    "test_gitStampCommit_idempotency"
    "test_gitStamp_reverse_single"
    "test_gitStampStressParity"
    "test_gitStampUniversalParity"
    "test_gitFindIdentity"
    "test_gitFindByStamp"
    "test_gitStampTransplantIntegration"
  )
  
  local ignored_tests=(
    "test_gitStampUniversalParity"
  )
  
  # bashTestRunner is a globally available utility per system requirements
  bashTestRunner test_functions ignored_tests
}
