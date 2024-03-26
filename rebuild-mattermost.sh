#! /usr/bin/env bash

set -euo pipefail
host="$1"

rsync -av --chown=mattermost:mattermost --chmod=g+w opt/mattermost/mattermost.scm root@"${host}":/stow/opt
ssh -t "${host}" "sudo -u mattermost /opt/mattermost/run.sh --help"
