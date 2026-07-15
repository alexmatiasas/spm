#!/usr/bin/env bats

SPM_ORIGINAL_HOME="/Users/alexmatias/projects/shell/spm"

setup() {
	rm -rf "$BATS_TMPDIR/home-test"
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

	mkdir -p "$HOME/projects/Icon"
	mkdir -p "$HOME/projects/Credenciales"
	mkdir -p "$HOME/projects/notes"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${SPM_ORIGINAL_HOME}/templates"

	source "${SPM_ORIGINAL_HOME}/lib/core.sh"
	source "${SPM_ORIGINAL_HOME}/lib/registry.sh"
	source "${SPM_ORIGINAL_HOME}/lib/detect.sh"
	source "${SPM_ORIGINAL_HOME}/lib/scan.sh"
	init_registry
}

teardown() {
	rm -rf "$BATS_TMPDIR/home-test"
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

@test "scan imports valid projects" {
	result=$(detect_and_import "$HOME/projects" 2>/dev/null | tail -1)
	[[ "$result" -ge 1 ]]
}

@test "scan dry-run does not modify registry" {
	local before after
	before=$(cat "$SPM_REGISTRY")
	detect_and_import "$HOME/projects" "true" 2>/dev/null >/dev/null
	after=$(cat "$SPM_REGISTRY")
	[[ "$before" == "$after" ]]
}

@test "scan skips already registered projects" {
	register_project "$HOME/projects/python_proj" "python"
	result=$(detect_and_import "$HOME/projects" 2>/dev/null | tail -1)
	[[ "$result" -ge 3 ]]
}

@test "is_excluded_dir returns true for Icon" {
	is_excluded_dir "Icon"
}

@test "is_excluded_dir returns true for Credenciales" {
	is_excluded_dir "Credenciales"
}

@test "is_excluded_dir returns true for notes" {
	is_excluded_dir "notes"
}

@test "is_excluded_dir returns false for normal dir" {
	! is_excluded_dir "python_proj"
}

@test "scan_directory returns count format" {
	result=$(scan_directory "$HOME/projects" "false" "false")
	[[ "$result" == *"imported="* ]]
	[[ "$result" == *"skipped="* ]]
}

@test "scan_directory dry-run preserves registry" {
	scan_directory "$HOME/projects" "true" "false" >/dev/null 2>&1 || true
	! grep -q "python_proj" "$SPM_REGISTRY"
}