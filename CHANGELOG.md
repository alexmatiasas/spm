## v0.1.0 (2026-07-15)

### Feat

- add README and LICENSE files
- **spm**: integrate sync changes and add interactivity
- **registry**: add repo_url support and rename
- **sync**: add lib/sync.sh with sync_directory
- **registry**: add getters for extended fields
- **scan**: add lib/scan.sh with directory scanning
- **cli**: update commands for new registry format
- **cli**: add list, sync, archive commands to spm
- **core**: add ID-based registry format with pipe separator
- **spm**: add install script
- **spm**: add lib modules (core, registry, wrapper)
- **spm**: add main spm script
- **makefile**: add makefile to run easily some commands
- **templates**: add js project template
- **templates**: add c++ project template
- **templates**: add shell project template
- **templates**: add rust project template
- **cz**: add .cz.toml configuration for conventional commits
- **templates**: add python project template
- **init**: initial commit

### Fix

- **build**: add a version file to be sincronized with cz CLI
- **gitignore**: add coverage to the gitignore
- **registry**: add || after grep to prevent set -e failure
- **spm**: remove set -e and rewrite cmd_sync inline
- **lib**: fix lib files to pass tests
- **wrapper**: source core.sh before using log_warn
- **config**: add message lenght limit to cz config file

### Refactor

- remove duplicate init_registry from core.sh
- simplify bin/spm with shared libs
- extract detect and validate to lib/
- **registry**: modify the style of the ID with timestamp
- **core**: add generate_uuid function for UUID IDs
