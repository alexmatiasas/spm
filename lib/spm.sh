#!/usr/bin/env bash
# spm wrapper for zsh - handles cd for 'spm ls'
if [[ -n "$ZSH_VERSION" ]]; then
	spm() {
		local cmd="$1"
		shift

		if [[ "$cmd" == "ls" ]]; then
			local dir
			dir=$(command spm-bin ls "$@")
			[[ -n "$dir" ]] && cd "$dir" || return 1
		else
			command spm-bin "$cmd" "$@"
		fi
	}
fi
