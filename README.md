# spm - Smart Project Manager

A shell-based CLI tool for managing personal projects across directories. Uses fzf for interactive project selection with auto-cd.

**Status: In Development** - Not yet ready for general use.

## Features

- **Project Registry** - Track projects with UUID, type, path, status
- **Interactive Selection** - Use fzf to select projects with auto-cd
- **Auto-Detection** - Detect project type by file markers (pyproject.toml, Cargo.toml, etc.)
- **Sync** - Detect new/removed projects from filesystem
- **Git Integration** - Extract remote URL automatically
- **Templates** - Create projects from templates (python, rust, shell, cpp, js)

## Quick Start

```bash
# Install
./bin/install.sh
export PATH="$HOME/bin:$PATH"

# Create a project
spm new python myproject

# List projects (fzf)
spm ls

# List projects (table)
spm list

# Scan for new projects
spm scan

# Sync registry with filesystem
spm sync
```

## Commands

| Command | Description |
|---------|-------------|
| `spm new <type> <name>` | Create project from template |
| `spm ls` | List projects via fzf with auto-cd |
| `spm list` | List projects as colored table |
| `spm info <id\|name>` | Show project details |
| `spm archive <id\|name>` | Archive project (mark as deleted) |
| `spm sync` | Sync registry with filesystem |
| `spm scan [dir]` | Scan directory for projects |
| `spm import <path> [type]` | Import existing project |

## Options

- `-d` - Dry-run (scan, import, sync)
- `-i` - Interactive mode (confirm each change)
- `-f` - Force re-import
- `-t <type>` - Override project type

## Registry Format

Pipe-separated with 9 fields:
```
ID|Name|Type|Created|Status|Path|LastAccess|RepoURL|Config
spm-a3f2|myproject|python|2024-04-22T23:42|active|/path/to/myproject||pyproject.toml
```

## Architecture

```
bin/spm           - Main CLI entry
lib/core.sh        - Colors, logging
lib/registry.sh  - CRUD operations
lib/detect.sh     - Project type detection
lib/validate.sh  - Input validation
lib/scan.sh       - Directory scanning
lib/sync.sh       - Registry sync
templates/        - Project templates
```

## Dependencies

- bash or zsh
- git
- fzf

## Current Limitations

**These issues need to be fixed before public release:**

1. **Hardcoded Paths** - The following paths are hardcoded:
   - `~/projects/shell/spm/lib` (library location)
   - `~/projects/shell/spm/templates` (templates location)
   - Projects directory: `~/projects`

2. **Installation** - Currently only works if spm is installed at `~/projects/shell/spm`
   - install.sh creates symlink to that specific path
   - bin/spm has hardcoded LIB_DIR

3. **macOS Only** - Uses macOS-specific flags (sed -i '')

4. **Registry Location** - Hardcoded to `~/.local/share/spm/registry`

## Planned Improvements

- [ ] Make library path configurable via environment variable
- [ ] Make templates location configurable
- [ ] Support custom project directories
- [ ] Add .spm/config per-project metadata
- [ ] Add git status to spm info
- [ ] Add groups/categories
- [ ] Cross-platform support (Linux, WSL)
- [ ] Export/import backup

## Testing

```bash
make test    # Run bats tests
make lint   # Run shellcheck + shfmt
```

## License

MIT

## Author

Alex Matias