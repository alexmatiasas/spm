#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"
	mkdir -p "$HOME/projects/myproject"
	touch "$HOME/projects/myproject/main.py"

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

detect_project_type() {
	local project_path="$1"

	if [[ -f "${project_path}/Cargo.toml" ]]; then
		echo "rust"
	elif [[ -f "${project_path}/pyproject.toml" ]] || [[ -f "${project_path}/requirements.txt" ]] || [[ -f "${project_path}/setup.py" ]] || [[ -f "${project_path}/main.py" ]]; then
		echo "python"
	elif [[ -f "${project_path}/package.json" ]]; then
		echo "js"
	elif [[ -f "${project_path}/CMakeLists.txt" ]]; then
		echo "cpp"
	elif [[ -d "${project_path}/.git" ]] || [[ -f "${project_path}/main.sh" ]]; then
		echo "shell"
	fi
}

@test "detect_project_type detects python by main.py" {
	result=$(detect_project_type "$HOME/projects/myproject")
	[[ "$result" == "python" ]]
}

@test "detect_project_type detects shell by main.sh" {
	mkdir -p "$HOME/projects/shellproject"
	touch "$HOME/projects/shellproject/main.sh"
	result=$(detect_project_type "$HOME/projects/shellproject")
	[[ "$result" == "shell" ]]
}

@test "detect_project_type returns empty for unknown type" {
	mkdir -p "$HOME/projects/unknown"
	result=$(detect_project_type "$HOME/projects/unknown")
	[[ -z "$result" ]]
}

@test "register_project adds project with active status" {
	register_project "$HOME/projects/myproject" "python"
	grep -q "myproject" "$SPM_REGISTRY"
	grep -q "active" "$SPM_REGISTRY"
}

@test "register_project adds project even for non-existent directory" {
	register_project "/nonexistent/path" "python"
	grep -q "path" "$SPM_REGISTRY"
}

@test "register_project works with specified type" {
	register_project "$HOME/projects/myproject" "shell"
	result=$(get_project_type "myproject")
	[[ "$result" == "shell" ]]
}