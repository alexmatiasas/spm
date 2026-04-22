#!/usr/bin/env bats

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"
	mkdir -p "$HOME/testproject"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${HOME}/projects/shell/spm/templates"

	init_registry
	register_project "$HOME/testproject" "python"
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
	rm -rf "$HOME/testproject"
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

get_project_info() {
	local project_path="$1"
	grep "^${project_path}" "${SPM_REGISTRY}" || return 1
}

parse_project_info() {
	local project_info="$1"
	echo "$project_info" | cut -f1
	echo "$project_info" | cut -f2
	echo "$project_info" | cut -f3
}

@test "info returns project path" {
	cd "$HOME/testproject"
	project_info=$(get_project_info "$HOME/testproject")
	path=$(echo "$project_info" | cut -f1)
	[[ "$path" == "$HOME/testproject" ]]
}

@test "info returns project type" {
	cd "$HOME/testproject"
	project_info=$(get_project_info "$HOME/testproject")
	type=$(echo "$project_info" | cut -f2)
	[[ "$type" == "python" ]]
}

@test "info returns timestamp" {
	cd "$HOME/testproject"
	project_info=$(get_project_info "$HOME/testproject")
	timestamp=$(echo "$project_info" | cut -f3)
	[[ "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]
}

@test "info returns empty when no project info" {
	init_registry
	result=$(get_project_info "/nonexistent/path" 2>/dev/null || echo "")
	[[ -z "$result" ]]
}