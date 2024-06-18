#!/usr/bin/env bash

# shellcheck disable=SC1091,SC2046,SC2086

cat << 'DESCRIPTION' >/dev/null
Alternative to devbox's inline `init_hook` for more complicated bootstrapping
DESCRIPTION

git_root="$(git rev-parse --show-toplevel 2>/dev/null)"
script_dir=$(dirname "$(readlink -f "$0")")

# get the root directory
if [ -n "$git_root" ]; then
	tld="$(git rev-parse --show-toplevel)"
else
	tld="${script_dir}"
fi

# source .env file skipping commented lines
dot_env() {
	env_file="${tld}/.env"
	if [ -f "${env_file}" ]; then
		export $(grep -v '^#' "${env_file}" | xargs)
	fi
}

# setup venv
activate_venv() {
	if [ -z "$VENV_DIR" ]; then
		VENV_DIR="${tld}/.venv"
	fi
	uv venv "${VENV_DIR}" --allow-existing
	source "${VENV_DIR}/bin/activate"
}


# install requirements
install_deps() {
	[[ -e "${tld}/requirements.txt"  ]] && uv pip install -r requirements.txt
}

main() {
	if [ $# -eq 0 ]; then
		dot_env
		activate_venv
		install_deps
	else
		while [[ $# -gt 0 ]]; do
			key="$1"
			case $key in
				-i|--init)
					dot_env
					activate_venv
					install_deps
					shift
					;;
				-e|--env)
					dot_env
					shift
					;;
				--venv)
					activate_venv
					shift
					;;
				--install)
					install_deps
					shift
					;;
				*)
					echo "Invalid argument: $key"
					exit 1
					;;
			esac
		done
	fi
}
main "$@"

exit 0
