#!/usr/bin/env bash
# Install spm to user's bin directory

set -euo pipefail

INSTALL_DIR="${HOME}/bin"
SPM_SOURCE="${HOME}/projects/shell/spm"
SPM_BIN="${SPM_SOURCE}/bin/spm"

main() {
	if [[ ! -d "${INSTALL_DIR}" ]]; then
		mkdir -p "${INSTALL_DIR}"
	fi

	if [[ ! -f "${SPM_BIN}" ]]; then
		echo "Error: spm binary not found at ${SPM_BIN}"
		exit 1
	fi

	ln -sf "${SPM_BIN}" "${INSTALL_DIR}/spm"
	echo "Installed spm to ${INSTALL_DIR}/spm"

	if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
		echo "Add this to your PATH in ~/.zshrc:"
		echo "  export PATH=\"\${HOME}/bin:\${PATH}\""
	fi
}

main "$@"
