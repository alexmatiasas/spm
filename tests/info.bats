#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"
	mkdir -p "$HOME/testproject"

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
	rm -rf "$HOME/testproject"
}

@test "info returns project by name" {
	register_project "$HOME/testproject" "python"
	project_info=$(get_project_info "testproject")
	[[ "$project_info" == *"testproject"* ]]
}

@test "info returns project type" {
	register_project "$HOME/testproject" "python"
	project_info=$(get_project_info "testproject")
	[[ "$project_info" == *"|python|"* ]]
}

@test "info returns timestamp" {
	register_project "$HOME/testproject" "python"
	project_info=$(get_project_info "testproject")
	[[ "$project_info" =~ \|[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\| ]]
}

@test "info returns status" {
	register_project "$HOME/testproject" "python"
	project_info=$(get_project_info "testproject")
	[[ "$project_info" == *active* ]]
}

@test "info returns empty when no project info" {
	init_registry
	result=$(get_project_info "nonexistent" 2>/dev/null || echo "")
	[[ -z "$result" ]]
}