#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"

	source "${SPM_ORIGINAL_HOME}/lib/validate.sh"
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
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

@test "validate_project_type rejects empty" {
	! validate_project_type ""
}

@test "is_valid_project_type returns true for valid" {
	is_valid_project_type "python"
}

@test "is_valid_project_type returns false for invalid" {
	! is_valid_project_type "go"
}

@test "validate_project_name accepts simple name" {
	validate_project_name "myproject"
}

@test "validate_project_name accepts nested name" {
	validate_project_name "data_science/my-project"
}

@test "validate_project_name accepts with underscores" {
	validate_project_name "my_project_name"
}

@test "validate_project_name accepts with dashes" {
	validate_project_name "my-project-name"
}

@test "validate_project_name accepts with slashes" {
	validate_project_name "path/to/project"
}

@test "validate_project_name rejects special chars" {
	! validate_project_name "my@project"
}

@test "validate_project_name rejects spaces" {
	! validate_project_name "my project"
}

@test "validate_project_name rejects dots" {
	! validate_project_name "my.project"
}

@test "validate_project_name rejects empty" {
	! validate_project_name ""
}