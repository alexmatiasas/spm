#!/usr/bin/env bash
# shellcheck disable=SC2154
# spm wrapper for zsh - handles cd for 'spm ls'

LIB_DIR="${HOME}/projects/shell/spm/lib"
source "${LIB_DIR}/core.sh"
source "${LIB_DIR}/registry.sh"

if [[ -n "$ZSH_VERSION" ]]; then
	spm() {
		local cmd="${1:-}"
		[[ -z "$cmd" ]] && {
			echo "Usage: spm <command>"
			echo "Commands: new, ls, list, import, scan, info, archive, sync"
			return 1
		}
		shift

		local spm_bin
		spm_bin="${HOME}/bin/spm"

		if [[ "$cmd" == "ls" ]]; then
			local dir
			dir=$("$spm_bin" ls "$@")
			if [[ -n "$dir" && -d "$dir" ]]; then
				cd "$dir" 2>/dev/null || {
					log_warn "Directory not found: $dir"
					return 1
				}
				local project_name
				project_name=$(basename "$dir")
				update_last_access "$project_name" 2>/dev/null
				echo "Moved to: $(basename "$dir")"
			else
				log_warn "No project selected"
				return 1
			fi
		else
			"$spm_bin" "$cmd" "$@"
		fi
	}
fi

spm_cd() {
	local project_name="$1"
	local path
	path=$(get_project_path "$project_name" 2>/dev/null)
	if [[ -n "$path" && -d "$path" ]]; then
		cd "$path" || {
			log_warn "Cannot cd to: $path"
			return 1
		}
		update_last_access "$project_name" 2>/dev/null
		echo "Moved to: $project_name"
	else
		log_warn "Project not found: $project_name"
		return 1
	fi
}
