# git-stamp-all-commits

Bulk stamp all commits in a Git repository with unique UUID stamps.

## Parameters

This command takes no parameters. It operates on the current Git repository.

## Usage Examples

```bash
# Stamp all commits in the current repository
git-stamp-all-commits

# Run from within any Git repository
cd /path/to/repo
git-stamp-all-commits
```

## Detailed Information

### How It Works
1. **Dependency Check**: Verifies `git-filter-repo` is installed and available
2. **Bulk Processing**: Uses `git-filter-repo` to process the entire commit history
3. **UUID Generation**: Automatically generates a new UUID for each commit that doesn't already have a stamp
4. **Message Modification**: Appends `uuid-stamp: <uuid>` to commit messages without altering other content

### Important Notes
⚠️ **WARNING**: This command rewrites Git history using `git filter-repo --force`
- This changes commit hashes for all stamped commits
- All collaborators must coordinate when using this tool
- Consider backing up your repository before running

### Dependencies
- `git-filter-repo` - Required for bulk history rewriting
- Python 3 - Required by git-filter-repo for callback execution
- `uuid` Python module - Standard library module for UUID generation

### Performance
- Processes the entire repository history in a single pass
- Only modifies commits without existing UUID stamps
- Maintains original commit metadata (author, date, etc.)
- Preserves commit message formatting

### Error Handling
- Returns error code 1 if `git-filter-repo` is not installed
- Returns error code from `git-filter-repo` if the operation fails
- Preserves existing stamps (does not overwrite them)

### Related Tools
This tool is part of a suite of Git stamping utilities:
- `git-stamp-commit` - Add UUID stamp to the current HEAD commit
- `git-find-by-stamp` - Search for commits by UUID stamp across repositories
- `git-stamp-info` - Display stamp information for a specific commit

### Use Cases
- Adding traceability to legacy repositories
- Preparing repositories for distributed tracing systems
- Creating unique identifiers for audit compliance
- Enabling cross-repository commit tracking

### Technical Implementation
The tool uses a Python callback with `git-filter-repo`:
```python
import uuid
import re
if b"uuid-stamp:" not in message:
    new_uuid = str(uuid.uuid4()).encode("utf-8")
    return message.rstrip() + b"

uuid-stamp: " + new_uuid + b"
"
return message
```

This ensures:
- UTF-8 encoding compatibility
- Proper newline handling
- Preservation of existing stamps
- Clean message formatting

### Safety Features
- Uses `--force` flag only after confirming git-filter-repo availability
- Maintains original message content (only appends stamp)
- Preserves commit ordering and parent relationships
- Handles binary data in commit messages safely
