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

list_projects() {
	awk -F'\t' '{print $1}' "${SPM_REGISTRY}"
}

@test "ls fails when no projects registered" {
	rm -f "${SPM_REGISTRY}"
	! list_projects
}

@test "ls returns projects when registered" {
	register_project "/tmp/project1" "python"
	register_project "/tmp/project2" "rust"
	result=$(list_projects)
	[[ "$result" == *"/tmp/project1"* ]]
	[[ "$result" == *"/tmp/project2"* ]]
}

@test "ls returns empty when registry empty" {
	init_registry
	result=$(list_projects)
	[[ -z "$result" ]]
}