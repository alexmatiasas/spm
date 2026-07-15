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
	rm -rf "$HOME/myproject" "$HOME/myproject-nogit" "$HOME/myproject-git"
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
	result=$(grep myproject "$SPM_REGISTRY" | cut -d'|' -f1)
	found=$(find_line "$result")
	[[ "$found" == *"myproject"* ]]
}

@test "find_line finds by name" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(find_line "myproject")
	[[ "$result" == *"myproject"* ]]
}

@test "register_project creates 9-field entry" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	field_count=$(awk -F'|' '{print NF}' "${SPM_REGISTRY}" | tail -1)
	[[ "$field_count" -eq 9 ]]
}

@test "get_project_last_access returns empty for new project" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(get_project_last_access "myproject")
	[[ -z "$result" ]]
}

@test "update_last_access sets timestamp" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	update_last_access "myproject"
	result=$(get_project_last_access "myproject")
	[[ -n "$result" ]]
	[[ "$result" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]
}

@test "get_project_repo_url returns empty for new project" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(get_project_repo_url "myproject")
	[[ -z "$result" ]]
}

@test "update_repo_url sets repo URL" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	update_repo_url "myproject" "https://github.com/user/repo"
	result=$(get_project_repo_url "myproject")
	[[ "$result" == "https://github.com/user/repo" ]]
}

@test "get_project_config returns empty for new project" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	result=$(get_project_config "myproject")
	[[ -z "$result" ]]
}

@test "get_git_remote returns empty for non-git dir" {
	mkdir -p "$HOME/myproject-nogit"
	result=$(get_git_remote "$HOME/myproject-nogit")
	[[ -z "$result" ]]
}

@test "get_git_remote returns remote for git repo" {
	mkdir -p "$HOME/myproject-git"
	git init -q "$HOME/myproject-git"
	git -C "$HOME/myproject-git" config remote.origin.url "git@github.com:user/repo.git"
	result=$(get_git_remote "$HOME/myproject-git")
	[[ "$result" == "git@github.com:user/repo.git" ]]
}

@test "set_project_deleted clears last_access" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	update_last_access "myproject"
	set_project_deleted "myproject"
	result=$(get_project_last_access "myproject")
	[[ -z "$result" ]]
}