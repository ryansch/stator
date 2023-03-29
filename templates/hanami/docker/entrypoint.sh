#!/bin/bash

set -euo pipefail

su-exec "${FIXUID:?Missing FIXUID var}:${FIXGID:?Missing FIXGID var}" fixuid

"${WORKSPACE_DIR}/docker/chown-dirs.sh"
set +e
su-exec deploy touch /home/deploy/.config/irb/irb_history
su-exec deploy ln -s /home/deploy/.config/irb/irb_history /home/deploy/.irb_history
set -e

install_tls_certs() {
  if [ -n "$(ls -A /usr/local/share/ca-certificates)" ]; then
    echo "Updating ca-certificates"
    update-ca-certificates
  fi
}
install_tls_certs

if [[ "$1" = 'bundle' ]] || [[ "$1" = 'yarn' ]]; then
  set -- su-exec deploy "$@"
  exec "$@"
fi

set -- su-exec deploy bundle exec "$@"

rm -f "${WORKSPACE_DIR}/tmp/pids/server.pid"

exec "$@"
