#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"
	mkdir -p "$HOME/projects/myproject"
	touch "$HOME/projects/myproject/main.py"

	mkdir -p "$HOME/projects/shellproject"
	touch "$HOME/projects/shellproject/main.sh"

	mkdir -p "$HOME/projects/rustproject"
	touch "$HOME/projects/rustproject/Cargo.toml"

	mkdir -p "$HOME/projects/jspproject"
	touch "$HOME/projects/jspproject/package.json"

	mkdir -p "$HOME/projects/cppproject"
	touch "$HOME/projects/cppproject/CMakeLists.txt"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${SPM_ORIGINAL_HOME}/templates"

	source "${SPM_ORIGINAL_HOME}/lib/core.sh"
	source "${SPM_ORIGINAL_HOME}/lib/registry.sh"
	source "${SPM_ORIGINAL_HOME}/lib/detect.sh"
	init_registry
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
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

@test "detect_project_type detects python by main.py" {
	result=$(detect_project_type "$HOME/projects/myproject")
	[[ "$result" == "python" ]]
}

@test "detect_project_type detects shell by main.sh" {
	result=$(detect_project_type "$HOME/projects/shellproject")
	[[ "$result" == "shell" ]]
}

@test "detect_project_type returns empty for unknown type" {
	result=$(detect_project_type "$HOME/projects")
	[[ -z "$result" ]]
}

@test "detect_project_type detects rust by Cargo.toml" {
	result=$(detect_project_type "$HOME/projects/rustproject")
	[[ "$result" == "rust" ]]
}

@test "detect_project_type detects js by package.json" {
	result=$(detect_project_type "$HOME/projects/jspproject")
	[[ "$result" == "js" ]]
}

@test "detect_project_type detects cpp by CMakeLists.txt" {
	result=$(detect_project_type "$HOME/projects/cppproject")
	[[ "$result" == "cpp" ]]
}