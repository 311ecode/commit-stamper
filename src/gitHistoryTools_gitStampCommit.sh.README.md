# git-stamp-info

Display UUID stamp information for a specific Git commit.

## Parameters

### Optional
- `[commit_hash]` - The commit hash to check (default: `HEAD`)
  - Can be any valid Git commit reference (hash, branch, tag, etc.)
  - Uses `HEAD` if no parameter is provided

## Usage Examples

```bash
# Check the current HEAD commit
git-stamp-info

# Check a specific commit by hash
git-stamp-info abc123def456

# Check a branch tip
git-stamp-info main

# Check a tagged commit
git-stamp-info v1.0.0

# Check the parent of current commit
git-stamp-info HEAD~1
```

## Detailed Information

### How It Works
1. **Commit Resolution**: Uses the provided commit reference or defaults to `HEAD`
2. **Stamp Extraction**: Parses the commit message to find the `uuid-stamp:` line
3. **Output Display**: Shows commit hash and stamp UUID in a clean format
4. **Error Handling**: Returns appropriate message if no stamp is found

### Output Format
When a stamp is found:
```
Commit: abc123def456...
Stamp:  123e4567-e89b-12d3-a456-426614174000
```

When no stamp is found:
```
No uuid-stamp found for <commit_reference>
```

### Error Handling
- Returns error code 1 if no UUID stamp is found for the specified commit
- Returns error code from `git log` if the commit reference is invalid
- Handles malformed commit messages gracefully

### Dependencies
- `git` - Must be installed and in PATH
- Standard Unix utilities: `grep`, `cut`

### Performance Notes
- Uses single `git log` call for efficiency
- Minimal text processing with `grep` and `cut`
- Fast execution even on large repositories

### Related Tools
This tool is part of a suite of Git stamping utilities:
- `git-stamp-commit` - Add UUID stamp to the current HEAD commit
- `git-stamp-all-commits` - Bulk stamp all commits in repository history
- `git-find-by-stamp` - Search for commits by UUID stamp across repositories

### Use Cases
- Verifying stamp presence on specific commits
- Debugging stamp-related issues
- Script integration for automated stamp validation
- Audit trail verification for compliance

### Technical Implementation
The tool extracts stamps using this pipeline:
1. `git log -1 --pretty=%B` - Gets the full commit message
2. `grep "^uuid-stamp:"` - Finds the stamp line (must be at start of line)
3. `cut -d' ' -f2` - Extracts just the UUID value

### Safety Features
- Non-destructive read-only operation
- Preserves repository state
- No history rewriting
- Safe to use on any Git repository
