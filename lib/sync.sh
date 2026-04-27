#!/usr/bin/env bash
# shellcheck disable=SC2154
# Sync utilities - compara registry con filesystem

get_project_git_remote() {
	local project_path="$1"
	[[ ! -d "$project_path/.git" ]] && return 1

	local remote_url
	remote_url=$(git -C "$project_path" config --get remote.origin.url 2>/dev/null) || return 1
	[[ -z "$remote_url" ]] && return 1
	echo "$remote_url"
}

get_project_key_files() {
	local project_path="$1"
	local project_type="$2"

	case "$project_type" in
	python)
		[[ -f "$project_path/pyproject.toml" ]] && echo "pyproject.toml"
		[[ -f "$project_path/requirements.txt" ]] && echo "requirements.txt"
		;;
	rust) [[ -f "$project_path/Cargo.toml" ]] && echo "Cargo.toml" ;;
	shell)
		[[ -f "$project_path/main.sh" ]] && echo "main.sh"
		[[ -f "$project_path/.git/main.sh" ]] && echo ".git/main.sh"
		;;
	cpp) [[ -f "$project_path/CMakeLists.txt" ]] && echo "CMakeLists.txt" ;;
	js) [[ -f "$project_path/package.json" ]] && echo "package.json" ;;
	*) ;;
	esac 2>/dev/null
}

identify_project() {
	local project_path="$1"
	local project_type="$2"

	local git_remote
	git_remote=$(get_project_git_remote "$project_path") && echo "git:$git_remote"

	local key_files
	key_files=$(get_project_key_files "$project_path" "$project_type") && echo "files:$key_files"
}

sync_directory() {
	local base_path="$1"
	local dry_run="${2:-false}"
	local interactive="${3:-false}"

	local new_projects=()
	local moved_projects=()
	local deleted_projects=()
	local unchanged=0

	while IFS= read -r line; do
		[[ -z "$line" ]] && continue

		local id name status stored_path
		id=$(echo "$line" | cut -d'|' -f1)
		name=$(echo "$line" | cut -d'|' -f2)
		status=$(echo "$line" | cut -d'|' -f5)
		stored_path=$(echo "$line" | cut -d'|' -f6)

		[[ "$status" != "active" ]] && continue
		[[ -z "$stored_path" ]] && continue

		if [[ ! -d "$stored_path" ]]; then
			deleted_projects+=("$id|$name|$stored_path")
		fi
	done <"${SPM_REGISTRY}"

	if [[ -d "$base_path" ]]; then
		while IFS= read -r project_dir; do
			[[ -z "$project_dir" ]] && continue
			[[ ! -d "$project_dir" ]] && continue

			local base_name
			base_name=$(basename "$project_dir")

			is_excluded_dir "$base_name" && continue

			local registered_line
			registered_line=$(find_line "$base_name" 2>/dev/null)

			if [[ -z "$registered_line" ]]; then
				local project_type
				project_type=$(detect_project_type "$project_dir")

				if [[ -n "$project_type" ]]; then
					if [[ "$interactive" == true ]]; then
						log_info "New project found: $base_name ($project_type)"
						echo -n "Import '$base_name'? [y/n]: "
						read -r answer
						if [[ "$answer" =~ ^[Yy]$ ]]; then
							new_projects+=("$project_dir|$project_type")
						fi
					else
						new_projects+=("$project_dir|$project_type")
					fi
				fi
			else
				local stored_path
				stored_path=$(echo "$registered_line" | cut -d'|' -f6)

				if [[ "$stored_path" != "$project_dir" ]]; then
					local stored_name
					stored_name=$(echo "$registered_line" | cut -d'|' -f2)

					if [[ -d "$stored_path" ]]; then
						if [[ "$interactive" == true ]]; then
							log_info "Project moved: $stored_name -> $base_name"
							echo -n "Update name from '$stored_name' to '$base_name'? [y/n]: "
							read -r answer
							if [[ "$answer" =~ ^[Yy]$ ]]; then
								moved_projects+=("$stored_name|$base_name")
							fi
						else
							moved_projects+=("$stored_name|$base_name")
						fi
					fi
				fi
				((unchanged++))
			fi
		done < <(find "$base_path" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
	fi

	local new_count=${#new_projects[@]}
	local deleted_count=${#deleted_projects[@]}
	local moved_count=${#moved_projects[@]}

	[[ $new_count -gt 0 ]] && log_info "New: $new_count"
	[[ $deleted_count -gt 0 ]] && log_info "Deleted: $deleted_count"
	[[ $moved_count -gt 0 ]] && log_info "Moved: $moved_count"

	printf 'new=%d deleted=%d moved=%d unchanged=%d' "$new_count" "$deleted_count" "$moved_count" "$unchanged"
}

prompt_action() {
	local message="$1"
	local prompt="$2"

	[[ -n "$prompt" ]] && message="$message ($prompt)"

	if [[ -z "$INTERACTIVE" ]]; then
		return 1
	fi

	echo "$message [y/n]"
	read -r answer
	[[ "$answer" =~ ^[Yy] ]]
}
