#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${SPM_ORIGINAL_HOME}/templates"

	source "${SPM_ORIGINAL_HOME}/lib/core.sh"
	source "${SPM_ORIGINAL_HOME}/lib/registry.sh"
	init_registry
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
}

@test "ls fails when no projects registered" {
	rm -f "${SPM_REGISTRY}"
	! list_projects
}

@test "ls returns only active projects by default" {
	mkdir -p "/tmp/alpha"
	mkdir -p "/tmp/beta"
	register_project "/tmp/alpha" "python"
	register_project "/tmp/beta" "rust"
	set_project_deleted "beta"
	result=$(list_projects)
	[[ "$result" == *"alpha"* ]]
	[[ "$result" != *"beta"* ]]
}

@test "ls -a returns all projects including deleted" {
	mkdir -p "/tmp/alpha"
	mkdir -p "/tmp/beta"
	register_project "/tmp/alpha" "python"
	register_project "/tmp/beta" "rust"
	set_project_deleted "beta"
	result=$(list_projects -a)
	[[ "$result" == *"alpha"* ]]
	[[ "$result" == *"beta"* ]]
}

@test "ls returns empty when registry empty" {
	init_registry
	result=$(list_projects)
	[[ -z "$result" ]]
}