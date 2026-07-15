#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${HOME}/bin"
SPM_SOURCE="${HOME}/projects/shell/spm"
SPM_BIN="${SPM_SOURCE}/bin/spm"
SPM_LIB="${SPM_SOURCE}/lib"

main() {
	if [[ ! -d "${INSTALL_DIR}" ]]; then
		mkdir -p "${INSTALL_DIR}"
	fi

	if [[ ! -f "${SPM_BIN}" ]]; then
		echo "Error: spm binary not found at ${SPM_BIN}"
		exit 1
	fi

	ln -sf "${SPM_BIN}" "${INSTALL_DIR}/spm"
	ln -sf "${SPM_BIN}" "${INSTALL_DIR}/spm-bin"
	echo "Installed spm to ${INSTALL_DIR}/spm"

	local zshrc_line="[[ -f \"\${HOME}/projects/shell/spm/lib/spm.sh\" ]] && source \"\${HOME}/projects/shell/spm/lib/spm.sh\""
	if ! grep -q "spm.sh" "${HOME}/.zshrc" 2>/dev/null; then
		{
			echo ""
			echo "# SPM wrapper"
			echo "$zshrc_line"
		} >>"${HOME}/.zshrc"
		echo "Added spm wrapper to ~/.zshrc"
	else
		echo "spm wrapper already in ~/.zshrc"
	fi

	if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
		echo "Add this to your PATH in ~/.zshrc:"
		echo "  export PATH=\"\${HOME}/bin:\${PATH}\""
	fi
}

main "$@"
