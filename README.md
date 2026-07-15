# spm

A shell-based CLI tool for managing personal projects across directories.
Uses fzf for interactive selection with auto-cd.

![demo](assets/demo.gif)

## What is spm?

`spm` is a command-line tool for managing your personal projects from one
central registry. It scaffolds new projects from built-in templates, tracks
them across directories, and lets you jump between them with fzf.

It combines the simplicity of a flat-file registry with auto-detection of
project types, so you can import existing projects and keep everything
organized without configuration files.

Projects are tracked in a pipe-separated flat file at
`~/.local/share/spm/registry`.

## Features (v0.1.0)

- Project registry with UUID, type, path, and status tracking
- Interactive project selection via fzf with auto-cd
- Auto-detection of project types by file markers
- Scaffolding from templates (Python, Rust, Shell, C++, JS)
- Filesystem sync — detect new and removed projects
- Git integration — extract remote URL automatically

## Quick Start

> Requires bash, git, and fzf.

```bash
git clone https://github.com/alexmatiasas/spm
cd spm
./bin/install.sh
export PATH="$HOME/bin:$PATH"

# Create a project
spm new python myproject

# List projects (fzf)
spm ls

# List projects (table)
spm list
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

| Flag | Description |
|------|-------------|
| `-d` | Dry-run (scan, import, sync) |
| `-i` | Interactive mode (confirm each change) |
| `-f` | Force re-import |
| `-t <type>` | Override project type |

## Project Structure

```
spm/
├── bin/
│   ├── spm                 # Main CLI entry
│   └── install.sh          # Installation script
├── lib/
│   ├── core.sh             # Config, colors, logging
│   ├── registry.sh         # CRUD operations
│   ├── detect.sh           # Project type detection
│   ├── validate.sh         # Input validation
│   ├── scan.sh             # Directory scanning
│   ├── sync.sh             # Registry sync
│   └── spm.sh              # Zsh wrapper for auto-cd
├── templates/              # Project templates
│   ├── python/
│   ├── rust/
│   ├── shell/
│   ├── cpp/
│   └── js/
├── tests/                  # 111 BATS tests
├── Makefile
└── LICENCE
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Bash |
| Selection | [fzf](https://github.com/junegunn/fzf) |
| Registry | Pipe-separated flat file |
| Hooks | [lefthook](https://github.com/evilmartians/lefthook) |
| Testing | [BATS](https://github.com/bats-core/bats-core) |
| Linting | shellcheck + shfmt |

## Development

### Prerequisites

- bash or zsh
- git
- fzf (`brew install fzf`)
- shellcheck (`brew install shellcheck`)

### Setup

```bash
git clone https://github.com/alexmatiasas/spm
cd spm
./bin/install.sh
export PATH="$HOME/bin:$PATH"
```

### Testing

```bash
make test
```

### Linting

```bash
make lint
```

## Limitations

1. **Hardcoded paths** — `LIB_DIR` and `SPM_TEMPLATES` are hardcoded to
   `~/projects/shell/spm`
2. **macOS only** — uses `sed -i ''` (BSD syntax)
3. **Registry location** — hardcoded to `~/.local/share/spm/registry`
4. **Installation** — requires spm source at `~/projects/shell/spm`

## Roadmap

- Configurable library and template paths
- Custom project directories
- Per-project `.spm/config` metadata
- Git status in `spm info`
- Cross-platform support (Linux, WSL)
- Export/import backup

## License

ISC — see [LICENSE](LICENSE).
