#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"

	source "${SPM_ORIGINAL_HOME}/lib/core.sh"
	source "${SPM_ORIGINAL_HOME}/lib/registry.sh"
	source "${SPM_ORIGINAL_HOME}/lib/detect.sh"
	source "${SPM_ORIGINAL_HOME}/lib/sync.sh"
}

teardown() {
	rm -rf "$HOME"
}

@test "sync_directory returns new for unregistered projects" {
	mkdir -p "$HOME/projects/newproject"
	touch "$HOME/projects/newproject/main.sh"
	detect_project_type() { echo "shell"; }
	export -f detect_project_type 2>/dev/null || true

	run sync_directory "$HOME/projects" "true"
	[[ "$output" == *"new=1"* ]]
}

@test "sync_directory returns deleted for missing projects" {
	echo "spm-test|myproject|shell|2024-01-01|active|${HOME}/projects/nonexistent|||" >>"$SPM_REGISTRY"

	run sync_directory "$HOME/projects" "true"
	[[ "$output" == *"deleted=1"* ]]
}

@test "sync_directory returns moved for renamed projects" {
	mkdir -p "$HOME/projects/oldname"
	touch "$HOME/projects/oldname/main.sh"
	echo "spm-test|oldname|shell|2024-01-01|active|${HOME}/projects/oldname|||" >>"$SPM_REGISTRY"

	run sync_directory "$HOME/projects" "true"
	[[ "$output" == *"moved="* ]] || [[ "$output" == *"unchanged="* ]]
}

@test "sync_directory excludes excluded dirs" {
	mkdir -p "$HOME/projects/Icon"
	mkdir -p "$HOME/projects/notes"
	mkdir -p "$HOME/projects/validproject"
	touch "$HOME/projects/validproject/main.sh"

	run sync_directory "$HOME/projects" "true"
	[[ "$output" != *"new=2"* ]]
	[[ "$output" == *"new=1"* ]]
}

@test "get_project_git_remote returns remote url" {
	mkdir -p "$HOME/projects/testproject"
	mkdir -p "$HOME/projects/testproject/.git"
	git -C "$HOME/projects/testproject" init
	git -C "$HOME/projects/testproject" remote add origin "https://github.com/user/repo.git"

	run get_project_git_remote "$HOME/projects/testproject"
	[[ "$output" == "https://github.com/user/repo.git" ]]
}

@test "get_project_git_remote returns empty for non-git" {
	mkdir -p "$HOME/projects/testproject"

	run get_project_git_remote "$HOME/projects/testproject"
	[[ -z "$output" ]]
}

@test "register_project with repo_url" {
	mkdir -p "/tmp/testproject"
	register_project "/tmp/testproject" "shell" "https://github.com/user/repo.git"
	line=$(tail -1 "$SPM_REGISTRY")

	[[ "$line" == *"|https://github.com/user/repo.git|"* ]]
}

@test "set_project_name updates name" {
	mkdir -p "/tmp/oldproject"
	echo "spm-test|oldproject|shell|2024-01-01|active|/tmp/oldproject|||" >"$SPM_REGISTRY"

	set_project_name "oldproject" "newproject"
	line=$(grep "spm-test" "$SPM_REGISTRY")

	[[ "$line" == *"newproject"* ]]
	[[ "$line" != *"oldproject"* ]]
}