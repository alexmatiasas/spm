#!/usr/bin/env bash
# shellcheck disable=SC2154
# Directory scanning utilities

EXCLUDED_DIRS="Icon Credenciales notes Planning Resources Videos Assets"

is_excluded_dir() {
	local dir_name="$1"
	[[ " $EXCLUDED_DIRS " == *" $dir_name "* ]]
}

scan_directory() {
	local base_path="$1"
	local dry_run="${2:-false}"
	local force="${3:-false}"

	local imported=0
	local skipped=0

	while IFS= read -r project_dir; do
		[[ -z "$project_dir" ]] && continue
		[[ ! -d "$project_dir" ]] && continue

		local base_name
		base_name=$(basename "$project_dir")

		if is_excluded_dir "$base_name"; then
			((skipped++))
			continue
		fi

		if [[ "$force" != true ]]; then
			if grep -q "|${base_name}|" "${SPM_REGISTRY}" 2>/dev/null; then
				((skipped++))
				continue
			fi
		fi

		local project_type
		project_type=$(detect_project_type "$project_dir")

		if [[ -z "$project_type" ]]; then
			((skipped++))
			continue
		fi

		if [[ "$dry_run" == true ]]; then
			log_info "Would import: $base_name ($project_type)"
		else
			if register_project "$project_dir" "$project_type" 2>/dev/null; then
				imported=$((imported + 1))
			else
				skipped=$((skipped + 1))
			fi
		fi
	done < <(find "$base_path" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

	printf 'imported=%d skipped=%d' "$imported" "$skipped"
}
