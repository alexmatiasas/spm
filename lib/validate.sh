#!/usr/bin/env bash
# shellcheck disable=SC2154
# Project validation utilities

VALID_PROJECT_TYPES=("python" "rust" "shell" "cpp" "js")

is_valid_project_type() {
	local project_type="$1"
	for valid in "${VALID_PROJECT_TYPES[@]}"; do
		[[ "$project_type" == "$valid" ]] && return 0
	done
	return 1
}

validate_project_type() {
	local project_type="$1"
	if ! is_valid_project_type "$project_type"; then
		return 1
	fi
}

validate_project_name() {
	local project_name="$1"
	[[ "$project_name" =~ ^[a-zA-Z0-9_/-]+$ ]]
}
