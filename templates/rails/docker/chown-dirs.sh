#!/usr/bin/env bash

chown_dir() {
  dir=$1
  if [[ -d "${dir}" ]] && [[ "$(stat -c %u:%g "${dir}")" != "${FIXUID}:${FIXGID}" ]]; then
    echo chown "$dir"
    chown deploy:deploy "$dir"
  fi
}

chown_r_dir() {
  dir=$1
  if [[ -d "${dir}" ]] && [[ "$(stat -c %u:%g "${dir}")" != "${FIXUID}:${FIXGID}" ]]; then
    echo chown -R "$dir"
    chown -R deploy:deploy "$dir"
  fi
}

ensure_dir() {
  dir=$1
  mkdir -p "$dir"

  chown_dir "$dir"
}

chown_r_dir "${WORKSPACE_DIR}"

chown_dir /usr/local/bundle
ensure_dir /home/deploy/.config/irb
