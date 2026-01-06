# git-find-by-stamp

Find Git repositories containing commits with a specific UUID stamp.

## Parameters

### Required
- `<uuid>` - The UUID stamp to search for. Can be either:
  - Just the UUID (e.g., `123e4567-e89b-12d3-a456-426614174000`)
  - Full `uuid-stamp: ...` line (e.g., `uuid-stamp: 123e4567-e89b-12d3-a456-426614174000`)

### Optional
- `[search_root]` - Directory to start searching from (default: current directory `.`)

## Usage Examples

```bash
# Search from current directory for a specific UUID
git-find-by-stamp 123e4567-e89b-12d3-a456-426614174000

# Search with full uuid-stamp line
git-find-by-stamp "uuid-stamp: 123e4567-e89b-12d3-a456-426614174000"

# Search from a specific directory
git-find-by-stamp 123e4567-e89b-12d3-a456-426614174000 /path/to/search

# Search from home directory
git-find-by-stamp 123e4567-e89b-12d3-a456-426614174000 ~
```

## Detailed Information

### How It Works
1. **UUID Extraction**: Automatically strips `uuid-stamp: ` prefix if provided
2. **Repository Discovery**: Recursively finds all `.git` directories within `search_root`
3. **Commit Search**: For each repository, searches all branches for commits containing the UUID stamp
4. **Output Format**: Displays matching repositories with commit hash and message

### Output Format
When a match is found, the tool displays:
```
[MATCH] Repo: /path/to/repository
        Hash: abc123def456...
        Msg:  Commit message (2 hours ago)
```

### Error Handling
- Returns error code 1 if no UUID is provided
- Silently skips directories without Git repositories
- Handles permission errors gracefully

### Dependencies
- `git` - Must be installed and in PATH
- `find` - Standard Unix utility
- `sed` - For UUID prefix stripping

### Performance Notes
- Searches all branches (`--all` flag)
- Returns only the first match per repository (`-n 1`)
- Uses `git -C` to operate on repositories without changing directories
- 2>/dev/null suppresses permission errors from `find`

### Related Tools
This tool is part of a suite of Git stamping utilities:
- `git-stamp-commit` - Add UUID stamps to individual commits
- `git-stamp-all-commits` - Bulk stamp all commits in history
- `git-stamp-info` - Display stamp information for a commit

### Use Cases
- Tracking specific commits across multiple repositories
- Verifying commit provenance in distributed systems
- Debugging deployment or synchronization issues
- Auditing commit history for compliance
