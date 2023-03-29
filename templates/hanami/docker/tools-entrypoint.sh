#!/bin/bash

set -euo pipefail

su-exec "${FIXUID:?Missing FIXUID var}:${FIXGID:?Missing FIXGID var}" fixuid > /dev/null 2>&1

"${WORKSPACE_DIR}/docker/chown-dirs.sh" > /dev/null

chown_r_dir() {
  dir="$1"
  if [[ -d "${dir}" ]] && [[ "$(stat -c %u:%g "${dir}")" != "${FIXUID}:${FIXGID}" ]]; then
    echo chown -R "$dir"
    chown -R deploy:deploy "$dir"
  fi
}

ensure_dir() {
  dir=$1
  mkdir -p "$dir"

  chown_r_dir "$dir"
}

ensure_dir /home/deploy/.solargraph/cache > /dev/null

if [ "${1:-}" = "bash" ]; then
  exec "$@"
elif [ "${1:-}" = "exit" ]; then
  exit 0
fi

set -- su-exec deploy "$@"
exec "$@"
