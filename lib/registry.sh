#!/usr/bin/env bash
# shellcheck disable=SC2154
# Registry utilities with UUID ID and path support
# Format: ID|Name|Type|Created|Status|Path|LastAccess|RepoURL|Config

export LC_ALL=C.UTF-8 2>/dev/null || true

generate_uuid() {
	local ts random
	ts=$(date +%s 2>/dev/null)
	[[ -z "$ts" ]] && ts="$$"
	random=$(((ts % 1000000) + ($$ % 1000) * 1000))
	local hash
	hash=$(printf '%x' "$random" 2>/dev/null)
	[[ -z "$hash" ]] && hash=$(printf '%x' "$$")
	hash="${hash:0:4}"
	printf 'spm-%s' "$hash"
}

register_project() {
	local project_path="$1"
	local project_type="$2"
	local timestamp
	timestamp=$(date +"%Y-%m-%dT%H:%M:%S")

	local project_name
	project_name=$(basename "$project_path")

	local new_id
	new_id=$(generate_uuid)

	if grep -q "|${project_name}|" "${SPM_REGISTRY}"; then
		log_warn "Project already exists: ${project_name}"
		return 1
	fi

	local new_line="${new_id}|${project_name}|${project_type}|${timestamp}|active|${project_path}|||"

	if [[ -s "${SPM_REGISTRY}" ]]; then
		local last_char
		last_char=$(tail -c 1 "${SPM_REGISTRY}")
		if [[ "$last_char" != "" ]]; then
			new_line="
$new_line"
		fi
	fi

	printf '%s\n' "$new_line" >>"${SPM_REGISTRY}"
	log_info "Registered: ${project_name} (${new_id})"
}

unregister_project() {
	local id_or_name="$1"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1

	local id
	id=$(echo "$line" | cut -d'|' -f1)
	local name
	name=$(echo "$line" | cut -d'|' -f2)
	local type
	type=$(echo "$line" | cut -d'|' -f3)
	local timestamp
	timestamp=$(echo "$line" | cut -d'|' -f4)

	sed -i '' "s|^${id}|${name}|${type}|${timestamp}|active$|${id}|${name}|${type}|${timestamp}|deleted|" "${SPM_REGISTRY}"
}

find_line() {
	local query="$1"
	awk -F'|' -v q="$query" '$1 == q || $2 == q && $2 != "--" {print; exit}' "${SPM_REGISTRY}"
}

get_project_info() {
	local id_or_name="$1"
	find_line "$id_or_name"
}

get_project_by_id() {
	local id="$1"
	grep "^${id}|" "${SPM_REGISTRY}" | grep -v "^|"
}

get_project_status() {
	local id_or_name="$1"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1
	echo "$line" | cut -d'|' -f5
}

get_project_name() {
	local id_or_name="$1"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1
	echo "$line" | cut -d'|' -f2
}

get_project_path() {
	local id_or_name="$1"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1
	echo "$line" | cut -d'|' -f6
}

get_project_type() {
	local id_or_name="$1"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1
	echo "$line" | cut -d'|' -f3
}

update_last_access() {
	local id_or_name="$1"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1

	local id name type path
	id=$(echo "$line" | cut -d'|' -f1)
	name=$(echo "$line" | cut -d'|' -f2)
	type=$(echo "$line" | cut -d'|' -f3)
	path=$(echo "$line" | cut -d'|' -f6)

	local timestamp
	timestamp=$(date +"%Y-%m-%dT%H:%M:%S")

	sed -i '' "s#${id}|${name}|${type}|.*|active|${path}|.*#${id}|${name}|${type}|.*|active|${path}|${timestamp}|#g" "${SPM_REGISTRY}"
}

update_repo_url() {
	local id_or_name="$1"
	local repo_url="$2"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1

	local id name path
	id=$(echo "$line" | cut -d'|' -f1)
	name=$(echo "$line" | cut -d'|' -f2)
	path=$(echo "$line" | cut -d'|' -f6)

	sed -i '' "s#${id}|${name}|.*|${path}|.*#${id}|${name}|.*|${path}||${repo_url}|#" "${SPM_REGISTRY}"
}

get_git_remote() {
	local project_path="$1"
	cd "$project_path" && git config --get remote.origin.url 2>/dev/null
}

list_projects() {
	local show_all=false
	if [[ "${1:-}" == "-a" ]] || [[ "${1:-}" == "--all" ]]; then
		show_all=true
	fi

	while IFS='|' read -r id name type date status path last_access repo_url config || [[ -n "$id" ]]; do
		[[ -z "$id" ]] && continue
		[[ "$id" == "ID" ]] && continue
		[[ "$id" == "--" ]] && continue
		[[ "$status" != "active" && "$show_all" != true ]] && continue
		echo "$name"
	done <"${SPM_REGISTRY}"
}

list_projects_full() {
	while IFS='|' read -r id name type date status path last_access repo_url config || [[ -n "$id" ]]; do
		[[ -z "$id" ]] && continue
		[[ "$id" == "ID" ]] && continue
		[[ "$id" == "--" ]] && continue
		echo "$id:$name:$type:$date:$status"
	done <"${SPM_REGISTRY}"
}

init_registry() {
	mkdir -p "${SPM_DATA_DIR}"
	if [[ ! -f "${SPM_REGISTRY}" ]]; then
		cat >"${SPM_REGISTRY}" <<'HEADER'
ID|Name|Type|Created|Status|Path|LastAccess|RepoURL|Config
--|----|----|------|--------------|-----------|--------
HEADER
	fi
}

set_project_deleted() {
	local id_or_name="$1"
	local line
	line=$(find_line "$id_or_name")
	[[ -z "$line" ]] && return 1

	local id name type path
	id=$(echo "$line" | cut -d'|' -f1)
	name=$(echo "$line" | cut -d'|' -f2)
	type=$(echo "$line" | cut -d'|' -f3)
	path=$(echo "$line" | cut -d'|' -f6)
	local timestamp
	timestamp=$(date +"%Y-%m-%dT%H:%M:%S")

	sed -i '' "s#${id}|${name}|${type}|.*|active|${path}|.*#${id}|${name}|${type}|${timestamp}|deleted|${path}||#" "${SPM_REGISTRY}"
}

set_project_moved() {
	local project_path="$1"
	local new_path="$2"
	local old_name
	old_name=$(basename "$project_path")
	local line
	line=$(find_line "$old_name")
	[[ -z "$line" ]] && return 1

	local id type new_name timestamp
	id=$(echo "$line" | cut -d'|' -f1)
	type=$(echo "$line" | cut -d'|' -f3)
	new_name=$(basename "$new_path")
	timestamp=$(date +"%Y-%m-%dT%H:%M:%S")

	sed -i '' "s#${id}|${old_name}|${type}|.*#${id}|${new_name}|${type}|${timestamp}|moved|${new_path}||#" "${SPM_REGISTRY}"
}
