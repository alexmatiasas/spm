#!/usr/bin/env bash
# shellcheck disable=SC2154
# Registry utilities: read, write, query projects

get_project_type() {
	local project_path="$1"
	awk -F'\t' -v path="${project_path}" '$1 == path {print $2}' "${SPM_REGISTRY}"
}

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

unregister_project() {
	local project_path="$1"
	sed -i '' "\|^${project_path}|d" "${SPM_REGISTRY}"
}

list_projects() {
	awk -F'\t' '{print $1}' "${SPM_REGISTRY}"
}

get_project_info() {
	local project_path="$1"
	grep "^${project_path}" "${SPM_REGISTRY}"
}
