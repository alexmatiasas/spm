#!/usr/bin/env bash
# shellcheck disable=SC2154
# Core utilities: config, logging, helpers

SPM_VERSION="0.1.0"
SPM_DIR="${HOME}/projects"
SPM_DATA_DIR="${HOME}/.local/share/spm"
SPM_REGISTRY="${SPM_DATA_DIR}/registry"
SPM_TEMPLATES="${HOME}/projects/shell/spm/templates"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

check_dependencies() {
	local missing=()
	local deps=("git" "fzf")

	for cmd in "${deps[@]}"; do
		if ! command -v "$cmd" &>/dev/null; then
			missing+=("$cmd")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		log_error "Missing dependencies: ${missing[*]}"
		log_error "Install them with your package manager"
		exit 1
	fi
}

init_registry() {
	mkdir -p "${SPM_DATA_DIR}"
	if [[ ! -f "${SPM_REGISTRY}" ]]; then
		touch "${SPM_REGISTRY}"
	fi
}

usage() {
	cat <<EOF
spm v${SPM_VERSION} - Smart Project Manager

Usage: spm <command> [options]

Commands:
    new <type> <name>     Create a new project
    ls                    List all projects (with fzf)
    info                  Show info about current project
    archive               Archive current project
    help                  Show this help

Options:
    -d, --dry-run         Show what would be done without doing it
    -h, --help            Show this help

Types for 'new':
    python, rust, shell, cpp, js

Examples:
    spm new python data_science/my-project
    spm ls
    spm info

EOF
}
