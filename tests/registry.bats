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

init_registry() {
	mkdir -p "${SPM_DATA_DIR}"
	if [[ ! -f "${SPM_REGISTRY}" ]]; then
		cat > "${SPM_REGISTRY}" <<'HEADER'
ID|Name|Type|Created|Status
--|----|----|------|------
HEADER
	fi
}

@test "register_project adds new entry with active status" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	grep -q "myproject" "$SPM_REGISTRY"
	grep -q "active" "$SPM_REGISTRY"
}

@test "get_project_type returns correct type" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(get_project_type "myproject")
	[[ "$result" == "python" ]]
}

@test "get_project_status returns active by default" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(get_project_status "myproject")
	[[ "$result" == "active" ]]
}

@test "set_project_deleted marks as deleted" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	set_project_deleted "myproject"
	result=$(get_project_status "myproject")
	[[ "$result" == "deleted" ]]
}

@test "set_project_moved changes path and status" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	set_project_moved "/tmp/myproject" "/tmp/myrenamed"
	grep -q "myrenamed" "$SPM_REGISTRY"
	result=$(get_project_status "myrenamed")
	[[ "$result" == "moved" ]]
}

@test "list_projects returns only active by default" {
	mkdir -p "/tmp/alpha"
	mkdir -p "/tmp/beta"
	register_project "/tmp/alpha" "python"
	register_project "/tmp/beta" "rust"
	set_project_deleted "beta"
	result=$(list_projects)
	[[ "$result" == *"alpha"* ]]
	[[ "$result" != *"beta"* ]]
}

@test "list_projects -a returns all including deleted" {
	mkdir -p "/tmp/alpha"
	mkdir -p "/tmp/beta"
	register_project "/tmp/alpha" "python"
	register_project "/tmp/beta" "rust"
	set_project_deleted "beta"
	result=$(list_projects -a)
	[[ "$result" == *"alpha"* ]]
	[[ "$result" == *"beta"* ]]
}

@test "get_project_info returns full line with status" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(get_project_info "myproject")
	[[ "$result" == *"myproject"* ]]
	[[ "$result" == *active* ]]
}

@test "find_line finds by ID" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(find_line "001")
	[[ "$result" == *"myproject"* ]]
}

@test "find_line finds by name" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(find_line "myproject")
	[[ "$result" == *"myproject"* ]]
}