#!/usr/bin/env bats

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${HOME}/projects/shell/spm/templates"

	init_registry
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
}

init_registry() {
	mkdir -p "${SPM_DATA_DIR}"
	if [[ ! -f "${SPM_REGISTRY}" ]]; then
		touch "${SPM_REGISTRY}"
	fi
}

get_project_type() {
	local project_path="$1"
	awk -F'\t' -v path="${project_path}" '$1 == path {print $2}' "${SPM_REGISTRY}"
}

register_project() {
	local project_path="$1"
	local project_type="$2"
	local timestamp
	timestamp=$(date +"%Y-%m-%dT%H:%M:%S")

	if grep -q "^${project_path}" "${SPM_REGISTRY}"; then
		sed -i '' "s|^${project_path}.*|${project_path}\t${project_type}\t${timestamp}|" "${SPM_REGISTRY}"
	else
		echo -e "${project_path}\t${project_type}\t${timestamp}" >>"${SPM_REGISTRY}"
	fi
}

unregister_project() {
	local project_path="$1"
	sed -i '' "\|^${project_path}|d" "${SPM_REGISTRY}"
}

list_projects() {
	awk -F'\t' '{print $1}' "${SPM_REGISTRY}"
}

get_project_info() {
	local project_path="$1"
	grep "^${project_path}" "${SPM_REGISTRY}"
}

@test "register_project adds new entry" {
	register_project "/tmp/test-project" "python"
	grep -q "/tmp/test-project" "$SPM_REGISTRY"
}

@test "get_project_type returns correct type" {
	register_project "/tmp/test-project" "python"
	result=$(get_project_type "/tmp/test-project")
	[[ "$result" == "python" ]]
}

@test "unregister_project removes entry" {
	register_project "/tmp/test-project" "python"
	unregister_project "/tmp/test-project"
	! grep -q "/tmp/test-project" "$SPM_REGISTRY"
}

@test "list_projects returns all paths" {
	register_project "/tmp/project1" "python"
	register_project "/tmp/project2" "rust"
	result=$(list_projects)
	[[ "$result" == *"/tmp/project1"* ]]
	[[ "$result" == *"/tmp/project2"* ]]
}

@test "register_project updates existing entry" {
	register_project "/tmp/test-project" "python"
	register_project "/tmp/test-project" "rust"
	result=$(get_project_type "/tmp/test-project")
	[[ "$result" == "rust" ]]
}

@test "get_project_info returns full line" {
	register_project "/tmp/test-project" "python"
	result=$(get_project_info "/tmp/test-project")
	[[ "$result" == $'/tmp/test-project\tpython\t'* ]]
}