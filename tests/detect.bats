#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"

	source "${SPM_ORIGINAL_HOME}/lib/detect.sh"
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
}

@test "detect_project_type handles nil path gracefully" {
	result=$(detect_project_type "" 2>/dev/null || echo "")
	[[ -z "$result" ]]
}

@test "detect_project_type detects rust by Cargo.toml" {
	mkdir -p "$HOME/projects/rust_proj"
	touch "$HOME/projects/rust_proj/Cargo.toml"
	result=$(detect_project_type "$HOME/projects/rust_proj")
	[[ "$result" == "rust" ]]
}

@test "detect_project_type detects python by main.py" {
	mkdir -p "$HOME/projects/python_proj"
	touch "$HOME/projects/python_proj/main.py"
	result=$(detect_project_type "$HOME/projects/python_proj")
	[[ "$result" == "python" ]]
}

@test "detect_project_type detects python by pyproject.toml" {
	mkdir -p "$HOME/projects/python_proj"
	touch "$HOME/projects/python_proj/pyproject.toml"
	result=$(detect_project_type "$HOME/projects/python_proj")
	[[ "$result" == "python" ]]
}

@test "detect_project_type detects python by requirements.txt" {
	mkdir -p "$HOME/projects/python_proj"
	touch "$HOME/projects/python_proj/requirements.txt"
	result=$(detect_project_type "$HOME/projects/python_proj")
	[[ "$result" == "python" ]]
}

@test "detect_project_type detects python by setup.py" {
	mkdir -p "$HOME/projects/python_proj"
	touch "$HOME/projects/python_proj/setup.py"
	result=$(detect_project_type "$HOME/projects/python_proj")
	[[ "$result" == "python" ]]
}

@test "detect_project_type detects js by package.json" {
	mkdir -p "$HOME/projects/js_proj"
	touch "$HOME/projects/js_proj/package.json"
	result=$(detect_project_type "$HOME/projects/js_proj")
	[[ "$result" == "js" ]]
}

@test "detect_project_type detects cpp by CMakeLists.txt" {
	mkdir -p "$HOME/projects/cpp_proj"
	touch "$HOME/projects/cpp_proj/CMakeLists.txt"
	result=$(detect_project_type "$HOME/projects/cpp_proj")
	[[ "$result" == "cpp" ]]
}

@test "detect_project_type detects cpp by src/main.cpp" {
	mkdir -p "$HOME/projects/cpp_proj/src"
	touch "$HOME/projects/cpp_proj/src/main.cpp"
	result=$(detect_project_type "$HOME/projects/cpp_proj")
	[[ "$result" == "cpp" ]]
}

@test "detect_project_type detects shell by main.sh" {
	mkdir -p "$HOME/projects/shell_proj"
	touch "$HOME/projects/shell_proj/main.sh"
	result=$(detect_project_type "$HOME/projects/shell_proj")
	[[ "$result" == "shell" ]]
}

@test "detect_project_type detects shell by .git dir" {
	mkdir -p "$HOME/projects/shell_proj/.git"
	result=$(detect_project_type "$HOME/projects/shell_proj")
	[[ "$result" == "shell" ]]
}

@test "detect_project_type returns empty for unknown" {
	mkdir -p "$HOME/projects/unknown_proj"
	result=$(detect_project_type "$HOME/projects/unknown_proj")
	[[ -z "$result" ]]
}

@test "detect_project_type rust takes precedence over python" {
	mkdir -p "$HOME/projects/both_proj"
	touch "$HOME/projects/both_proj/Cargo.toml"
	touch "$HOME/projects/both_proj/main.py"
	result=$(detect_project_type "$HOME/projects/both_proj")
	[[ "$result" == "rust" ]]
}

@test "detect_project_type python takes precedence over js" {
	mkdir -p "$HOME/projects/both_proj"
	touch "$HOME/projects/both_proj/pyproject.toml"
	touch "$HOME/projects/both_proj/package.json"
	result=$(detect_project_type "$HOME/projects/both_proj")
	[[ "$result" == "python" ]]
}

@test "detect_project_type cpp takes precedence over shell" {
	mkdir -p "$HOME/projects/both_proj"
	touch "$HOME/projects/both_proj/CMakeLists.txt"
	touch "$HOME/projects/both_proj/main.sh"
	result=$(detect_project_type "$HOME/projects/both_proj")
	[[ "$result" == "cpp" ]]
}

@test "detect_project_type non-existent directory returns empty" {
	result=$(detect_project_type "/nonexistent/path")
	[[ -z "$result" ]]
}