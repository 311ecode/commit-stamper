# Git Stamping Tools

A suite of Bash utilities for adding, finding, and managing UUID stamps in Git commit messages. These tools enable cross-repository commit tracking, audit trails, and enhanced traceability for distributed systems.

## Tools Overview

| Tool | Description | Key Feature |
|------|-------------|-------------|
| `git-stamp-commit` | Add UUID stamp to current HEAD commit | Single commit stamping |
| `git-stamp-all-commits` | Bulk stamp all commits in repository | History rewriting |
| `git-find-by-stamp` | Search for commits by UUID across repositories | Cross-repo search |
| `git-stamp-info` | Display stamp information for a commit | Stamp inspection |

## Quick Start

### Basic Usage

1. **Stamp a single commit:**
   ```bash
   cd /path/to/repo
   git-stamp-commit
   ```

2. **Find a stamped commit:**
   ```bash
   git-find-by-stamp 123e4567-e89b-12d3-a456-426614174000
   ```

3. **Check stamp information:**
   ```bash
   git-stamp-info
   ```

## Tool Details

### git-stamp-commit
Add a unique UUID stamp to the current HEAD commit.

**Parameters:** None  
**Usage:** `git-stamp-commit`

### git-stamp-all-commits
Bulk stamp all commits in repository history (requires git-filter-repo).

**Parameters:** None  
**Usage:** `git-stamp-all-commits`

### git-find-by-stamp
Search for commits with a specific UUID stamp across multiple repositories.

**Parameters:**
- `<uuid>` - UUID stamp to search for (required)
- `[search_root]` - Directory to start search (default: `.`)

**Usage:**
```bash
git-find-by-stamp <uuid> [search_root]
```

### git-stamp-info
Display UUID stamp information for a specific commit.

**Parameters:**
- `[commit_hash]` - Commit to check (default: `HEAD`)

**Usage:**
```bash
git-stamp-info [commit_hash]
```

## Common Workflows

### Adding Traceability to New Commits
```bash
# Make your changes
git add .
git commit -m "Implement feature X"

# Add UUID stamp for tracking
git-stamp-commit
```

### Auditing Existing Repositories
```bash
# Bulk stamp all historical commits
git-stamp-all-commits

# Verify stamps were added
git-stamp-info HEAD~5
```

### Cross-Repository Tracking
```bash
# Get UUID from commit
git-stamp-info

# Search for same commit in other repositories
git-find-by-stamp 123e4567-e89b-12d3-a456-426614174000 ~/projects
```

## Important Warnings

⚠️ **History Rewriting Tools**
- `git-stamp-commit` uses `git commit --amend`
- `git-stamp-all-commits` uses `git filter-repo --force`
- Both change commit hashes
- Coordinate with collaborators before use
- Consider backing up repositories

## Dependencies

| Tool | Dependencies |
|------|-------------|
| All tools | `git` |
| `git-stamp-commit` | `/proc/sys/kernel/random/uuid` or `uuidgen` |
| `git-stamp-all-commits` | `git-filter-repo`, Python 3 |
| `git-find-by-stamp` | `find`, `sed` |
| `git-stamp-info` | `grep`, `cut` |

## Output Examples

### git-stamp-commit
```
✅ Stamped HEAD with: 123e4567-e89b-12d3-a456-426614174000
```

### git-find-by-stamp
```
🔍 Searching for uuid-stamp: 123e4567-e89b-12d3-a456-426614174000 in /home/user/projects...
[MATCH] Repo: /home/user/projects/api-service
        Hash: abc123def456789
        Msg:  Fix authentication bug (2 hours ago)
```

### git-stamp-info
```
Commit: abc123def456789
Stamp:  123e4567-e89b-12d3-a456-426614174000
```

## Use Cases

- **Deployment Tracking:** Correlate commits across dev, staging, and production
- **Audit Compliance:** Create unique identifiers for regulatory requirements
- **Debugging:** Trace commit provenance in distributed systems
- **Synchronization:** Verify commit consistency across repository mirrors
- **Monitoring:** Track commit flow through CI/CD pipelines

## Technical Notes

- Stamps are added as `uuid-stamp: <uuid>` lines in commit messages
- UUIDs follow RFC 4122 format
- Tools preserve existing commit metadata (author, date, etc.)
- Search tools handle permission errors gracefully
- All tools are Bash functions, not standalone executables

## Troubleshooting

**"ERROR: Could not generate UUID"**
- Install `uuidgen` or ensure `/proc/sys/kernel/random/uuid` exists

**"ERROR: git-filter-repo is required"**
- Install git-filter-repo: `pip install git-filter-repo`

**No matches found in git-find-by-stamp**
- Verify the UUID is correct
- Check that repositories have been stamped
- Ensure search directory contains Git repositories

## Related Projects

These tools are designed to work with:
- CI/CD systems that need commit tracking
- Audit and compliance frameworks
- Distributed version control workflows
- Deployment verification systems

## License

These tools are provided as-is for practical use. Modify and distribute as needed for your workflow.
