#!/usr/bin/env bash

# This is the startup script for the mattermost server. It is not written
# directly to the systemd because we want exec, so that systemd can monitor
# this process directly, and because split nature of args (with --) becomes
# long, unwieldy, and possibly hard to parse in the service file.

set -eu
path=$(guix time-machine --commit=v1.4.0 -- build -f /opt/mattermost/mattermost.scm)
exec ${path}/bin/mattermost -c /opt/mattermost/config/config.json "$@"
