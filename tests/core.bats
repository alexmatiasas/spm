#!/usr/bin/env bats

setup() {
	export HOME="$BATS_TMPDIR/home-test"
	mkdir -p "$HOME/.local/share/spm"
	mkdir -p "$HOME/projects"

	SPM_DIR="${HOME}/projects"
	SPM_DATA_DIR="${HOME}/.local/share/spm"
	SPM_REGISTRY="${SPM_DATA_DIR}/registry"
	SPM_TEMPLATES="${HOME}/projects/shell/spm/templates"
}

teardown() {
	rm -rf "$HOME/.local/share/spm"
	rm -rf "$HOME/projects"
}

init_registry() {
	mkdir -p "${SPM_DATA_DIR}"
	if [[ ! -f "${SPM_REGISTRY}" ]]; then
		touch "${SPM_REGISTRY}"
	fi
}

log_info() { echo "[INFO] $*"; }
log_success() { echo "[OK] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

@test "log_info outputs [INFO]" {
	run log_info "test message"
	[[ "$output" == "[INFO] test message" ]]
}

@test "log_success outputs [OK]" {
	run log_success "test message"
	[[ "$output" == "[OK] test message" ]]
}

@test "log_warn outputs [WARN]" {
	run log_warn "test message"
	[[ "$output" == "[WARN] test message" ]]
}

@test "log_error outputs [ERROR] to stderr" {
	run log_error "test message"
	[[ "$output" == "[ERROR] test message" ]]
}

@test "init_registry creates registry file" {
	init_registry
	[[ -f "$SPM_REGISTRY" ]]
}

@test "init_registry creates data directory" {
	init_registry
	[[ -d "$SPM_DATA_DIR" ]]
}

@test "registry file is writable" {
	init_registry
	[[ -w "$SPM_REGISTRY" ]]
}