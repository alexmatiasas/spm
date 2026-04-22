#!/usr/bin/env bats

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"
	mkdir -p "$HOME/projects/archive"
	mkdir -p "$HOME/testproject"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${HOME}/projects/shell/spm/templates"
	ARCHIVE_DIR="${SPM_DIR}/archive"

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

unregister_project() {
	local project_path="$1"
	sed -i '' "\|^${project_path}|d" "${SPM_REGISTRY}" || true
}

get_project_name() {
	local project_path="$1"
	basename "$project_path"
}

archive_project() {
	local project_path="$1"
	local project_name
	project_name=$(basename "$project_path")
	local archive_path="${ARCHIVE_DIR}/${project_name}"

	mkdir -p "${ARCHIVE_DIR}"
	mv "${project_path}" "${archive_path}/"
	unregister_project "${project_path}"
}

@test "archive removes project from registry" {
	cd "$HOME/testproject"
	archive_project "$HOME/testproject"
	! grep -q "$HOME/testproject" "$SPM_REGISTRY"
}

@test "archive moves project to archive dir" {
	cd "$HOME/testproject"
	archive_project "$HOME/testproject"
	[[ -d "$HOME/projects/archive/testproject" ]]
}

@test "archive creates archive directory if not exists" {
	rm -rf "$HOME/projects/archive"
	archive_project "$HOME/testproject"
	[[ -d "$HOME/projects/archive" ]]
}

@test "get_project_name extracts basename" {
	result=$(get_project_name "/home/user/projects/myproject")
	[[ "$result" == "myproject" ]]
}