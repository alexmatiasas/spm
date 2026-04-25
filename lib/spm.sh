#!/usr/bin/env bash
# shellcheck disable=SC2154
# spm wrapper for zsh - handles cd for 'spm ls'
if [[ -n "$ZSH_VERSION" ]]; then
	spm() {
		local cmd="${1:-}"
		[[ -z "$cmd" ]] && {
			echo "Usage: spm <command>"
			echo "Commands: new, ls, import, scan, info, archive, sync"
			return 1
		}
		shift

		local spm_bin
		spm_bin="${HOME}/bin/spm"

		if [[ "$cmd" == "ls" ]]; then
			local dir
			dir=$("$spm_bin" ls "$@")
			if [[ -n "$dir" && -d "$dir" ]]; then
				cd "$dir" 2>/dev/null || return 1
				echo "Moved to: $(basename "$dir")"
			else
				return 1
			fi
		else
			"$spm_bin" "$cmd" "$@"
		fi
	}
fi
