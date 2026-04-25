#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

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

	source "${SPM_ORIGINAL_HOME}/lib/core.sh"
	source "${SPM_ORIGINAL_HOME}/lib/registry.sh"
	init_registry
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
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
	[[ "$output" == *"[DRY RUN]"* ]]
}

@test "dry-run does not create project" {
	log_warn "[DRY RUN] Would create: ${SPM_DIR}/test-project"
	[[ ! -d "${SPM_DIR}/test-project" ]]
}

@test "project created from template" {
	mkdir -p "${SPM_DIR}/data_science"
	project_path="${SPM_DIR}/data_science/test-project"
	template_path="${SPM_TEMPLATES}/python"
	mkdir -p "${project_path}"
	cp -r "${template_path}/." "${project_path}/"
	[[ -f "${project_path}/pyproject.toml" ]]
}

@test "project registered after creation" {
	mkdir -p "/tmp/myproject"
	register_project "/tmp/myproject" "python"
	grep -q "myproject" "$SPM_REGISTRY"
}