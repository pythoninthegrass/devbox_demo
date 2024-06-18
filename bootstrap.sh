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

# set the venv directory
if [ -z "$VENV_DIR" ]; then
	VENV_DIR="${tld}/.venv"
fi

# create the venv
uv venv "${VENV_DIR}" --allow-existing

# activate the venv
source "${VENV_DIR}/bin/activate"

# install requirements
[[ -e "${tld}/requirements.txt"  ]] && uv pip install -r requirements.txt

# run initdb and createdb
# * du/stat clocks default size to ~39160
pg_dir="${tld}/.devbox/virtenv/postgresql"
dir_size=$(du -s "${pg_dir}" 2>/dev/null | awk '{print $1}')
if [ -n "$PGHOST" ] && [ "$PG_TYPE" = 'local' ]; then
	if [ ! -d "$pg_dir" ] || (( "$dir_size" < 39000 )); then
		# initdb
		initdb -D "${PGDATA}" --auth-local=trust --auth-host=trust

		# create the database
		createdb "${PGDATABASE}" 2>/dev/null
	fi
fi

exit 0
