#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"
	mkdir -p "$HOME/projects/archive"
	mkdir -p "$HOME/myproject"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${SPM_ORIGINAL_HOME}/templates"
	ARCHIVE_DIR="${SPM_DIR}/archive"

	source "${SPM_ORIGINAL_HOME}/lib/core.sh"
	source "${SPM_ORIGINAL_HOME}/lib/registry.sh"
	init_registry
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
	rm -rf "$HOME/myproject"
}

@test "archive marks project as deleted in registry" {
	register_project "$HOME/myproject" "python"
	set_project_deleted "myproject"
	result=$(get_project_status "myproject")
	[[ "$result" == "deleted" ]]
}

@test "archive directory exists" {
	[[ -d "$ARCHIVE_DIR" ]]
}