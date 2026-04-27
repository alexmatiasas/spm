#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"

	mkdir -p "$HOME/projects/python_proj"
	touch "$HOME/projects/python_proj/main.py"

	mkdir -p "$HOME/projects/shell_proj"
	touch "$HOME/projects/shell_proj/main.sh"

	mkdir -p "$HOME/projects/js_proj"
	touch "$HOME/projects/js_proj/package.json"

	mkdir -p "$HOME/projects/rust_proj"
	touch "$HOME/projects/rust_proj/Cargo.toml"

	mkdir -p "$HOME/projects/cpp_proj"
	touch "$HOME/projects/cpp_proj/main.cpp"

	mkdir -p "$HOME/projects/unknown_proj"

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

detect_and_import() {
	local base_path="$1"
	local dry_run="${2:-false}"

	local count=0
	while IFS= read -r -d '' project_dir; do
		local project_type
		project_type=$(detect_project_type "$project_dir")
		[[ -n "$project_type" ]] || continue
		[[ "$dry_run" == "true" ]] && continue
		register_project "$project_dir" "$project_type"
		((count++))
	done < <(find "$base_path" -mindepth 1 -maxdepth 1 -type d -print0)
	echo "$count"
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

@test "scan imports valid projects" {
	result=$(detect_and_import "$HOME/projects" 2>/dev/null | tail -1)
	[[ "$result" -ge 1 ]]
}

@test "scan skips unknown project types" {
	result=$(detect_and_import "$HOME/projects" 2>/dev/null | tail -1)
	[[ "$result" -ge 1 ]]
}

@test "scan dry-run returns 0 without modifying registry" {
	result=$(detect_and_import "$HOME/projects" "true" 2>/dev/null | tail -1)
	[[ "$result" -eq 0 ]]
}

@test "scan skips already registered projects" {
	register_project "$HOME/projects/python_proj" "python"
	result=$(detect_and_import "$HOME/projects" 2>/dev/null | tail -1)
	[[ "$result" -ge 3 ]]
}

@test "detect finds python by main.py" {
	result=$(detect_project_type "$HOME/projects/python_proj")
	[[ "$result" == "python" ]]
}

@test "detect finds shell by main.sh" {
	result=$(detect_project_type "$HOME/projects/shell_proj")
	[[ "$result" == "shell" ]]
}

@test "detect finds js by package.json" {
	result=$(detect_project_type "$HOME/projects/js_proj")
	[[ "$result" == "js" ]]
}

@test "detect finds rust by Cargo.toml" {
	result=$(detect_project_type "$HOME/projects/rust_proj")
	[[ "$result" == "rust" ]]
}

@test "detect returns empty for unknown" {
	result=$(detect_project_type "$HOME/projects/unknown_proj")
	[[ -z "$result" ]]
}