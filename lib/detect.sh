#!/usr/bin/env bash
# shellcheck disable=SC2154
# Project type detection by file markers

detect_project_type() {
	local project_path="$1"
	[[ -z "$project_path" ]] && return 1

	if [[ -f "${project_path}/Cargo.toml" ]]; then
		echo "rust"
	elif [[ -f "${project_path}/pyproject.toml" ]] ||
		[[ -f "${project_path}/requirements.txt" ]] ||
		[[ -f "${project_path}/setup.py" ]] ||
		[[ -f "${project_path}/main.py" ]]; then
		echo "python"
	elif [[ -f "${project_path}/package.json" ]]; then
		echo "js"
	elif [[ -f "${project_path}/CMakeLists.txt" ]] ||
		{ [[ -d "${project_path}/src" ]] && [[ -f "${project_path}/src/main.cpp" ]]; }; then
		echo "cpp"
	elif [[ -d "${project_path}/.git" ]] || [[ -f "${project_path}/main.sh" ]]; then
		echo "shell"
	fi
}
