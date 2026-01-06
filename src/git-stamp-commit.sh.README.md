# git-stamp-commit

Add a unique UUID stamp to the current HEAD commit in a Git repository.

## Parameters

This command takes no parameters. It operates on the current HEAD commit of the repository you're in.

## Usage Examples

```bash
# Stamp the current HEAD commit
git-stamp-commit

# Run from within any Git repository
cd /path/to/repo
git-stamp-commit
```

## Detailed Information

### How It Works
1. **UUID Generation**: Generates a unique UUID using system methods
   - Tries `/proc/sys/kernel/random/uuid` (Linux-specific)
   - Falls back to `uuidgen` command if available
2. **Duplicate Check**: Verifies the commit doesn't already have a UUID stamp
3. **Commit Amendment**: Appends the UUID stamp to the commit message while preserving all original metadata

### Important Notes
⚠️ **WARNING**: This command uses `git commit --amend` which rewrites Git history
- This changes the commit hash of the current HEAD
- Use with caution on shared branches
- Consider coordinating with collaborators before using

### Dependencies
- `git` - Must be installed and in PATH
- UUID generation requires either:
  - Linux kernel `/proc/sys/kernel/random/uuid` interface, OR
  - `uuidgen` command (typically from `uuid-runtime` package)

### Output Format
- Success: `✅ Stamped HEAD with: <uuid>`
- Already stamped: `⚠️  Commit already has a uuid-stamp.`
- Error: `ERROR: Could not generate UUID. Ensure /proc/sys/kernel/random/uuid exists or install uuidgen.`

### Error Handling
- Returns error code 1 if UUID generation fails
- Returns error code 0 if commit is already stamped (treated as success)
- Returns error code from `git commit --amend` if the operation fails

### Related Tools
This tool is part of a suite of Git stamping utilities:
- `git-stamp-all-commits` - Bulk stamp all commits in repository history
- `git-find-by-stamp` - Search for commits by UUID stamp across repositories
- `git-stamp-info` - Display stamp information for a specific commit

### Use Cases
- Adding traceable identifiers to important commits
- Creating unique markers for deployment tracking
- Enabling cross-repository commit correlation
- Audit trail creation for compliance requirements

### Technical Implementation
The stamp is added as a new line at the end of the commit message:
```
Original commit message...

uuid-stamp: 123e4567-e89b-12d3-a456-426614174000
```

### Safety Features
- Uses `--no-edit` flag to preserve original commit metadata (author, date, etc.)
- Uses `--quiet` flag to suppress unnecessary output
- Checks for existing stamps to prevent duplication
- Preserves all original commit message content
