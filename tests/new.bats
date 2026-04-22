#!/usr/bin/env bats

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"
	mkdir -p "$HOME/projects/shell/spm/templates/python"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${HOME}/projects/shell/spm/templates"

	touch "${SPM_TEMPLATES}/python/pyproject.toml"

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

log_info() { echo "[INFO] $*"; }
log_success() { echo "[OK] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

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

validate_project_type() {
	local project_type="$1"
	local valid_types=("python" "rust" "shell" "cpp" "js")
	if [[ ! ${valid_types[*]} =~ (^| )"${project_type}"( |$) ]]; then
		return 1
	fi
}

validate_project_name() {
	local project_name="$1"
	if [[ ! "$project_name" =~ ^([a-zA-Z0-9_/-]+)$ ]]; then
		return 1
	fi
}

@test "validate_project_type accepts python" {
	validate_project_type "python"
}

@test "validate_project_type accepts rust" {
	validate_project_type "rust"
}

@test "validate_project_type accepts shell" {
	validate_project_type "shell"
}

@test "validate_project_type accepts cpp" {
	validate_project_type "cpp"
}

@test "validate_project_type accepts js" {
	validate_project_type "js"
}

@test "validate_project_type rejects invalid type" {
	! validate_project_type "invalid"
}

@test "validate_project_name accepts simple name" {
	validate_project_name "myproject"
}

@test "validate_project_name accepts nested name" {
	validate_project_name "data_science/my-project"
}

@test "validate_project_name rejects special chars" {
	! validate_project_name "my@project"
}

@test "validate_project_name rejects spaces" {
	! validate_project_name "my project"
}

@test "dry-run outputs message" {
	run log_warn "[DRY RUN] Would create: ${SPM_DIR}/test-project"
	[[ "$output" == *"[DRY RUN] Would create"* ]]
}

@test "dry-run does not create project" {
	local dry_run=true
	local project_path="${SPM_DIR}/test-project"

	! [[ -d "$project_path" ]]
}

@test "project created from template" {
	local project_path="${SPM_DIR}/test-project"
	local template_path="${SPM_TEMPLATES}/python"

	mkdir -p "${project_path}"
	cp -r "${template_path}/." "${project_path}/"

	[[ -f "${project_path}/pyproject.toml" ]]
}

@test "project registered after creation" {
	local project_path="${SPM_DIR}/test-project"
	local project_type="python"

	mkdir -p "${project_path}"
	register_project "${project_path}" "${project_type}"

	grep -q "${project_path}" "$SPM_REGISTRY"
}
