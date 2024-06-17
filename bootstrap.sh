#!/usr/bin/env bash

# shellcheck disable=SC1091

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

# set the venv directory
if [ -z "$VENV_DIR" ]; then
	VENV_DIR="${tld}/.venv"
fi

# create the venv
uv venv "${VENV_DIR}" --allow-existing

# install requirements
[[ -e "${tld}/requirements.txt"  ]] && uv pip install -r requirements.txt

exit 0
