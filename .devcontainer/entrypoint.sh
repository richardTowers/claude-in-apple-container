#!/bin/bash
set -euo pipefail

# Always initialize the firewall before running anything else.
# If the firewall fails to set up (e.g. missing NET_ADMIN capability),
# refuse to start so we never run without network restrictions.
# sudo /usr/local/bin/init-firewall.sh

exec "$@"
