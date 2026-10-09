#!/usr/bin/env bash
# Run from your Mac after `git push`:  ./deploy/deploy.sh
# Pulls the latest commit on the Hostinger VPS.
set -euo pipefail
SERVER="${SERVER:-root@YOUR_VPS_IP}"      # or your ssh alias from ~/.ssh/config
APP_DIR="${APP_DIR:-/var/www/cammodoro}"
ssh "$SERVER" "cd '$APP_DIR' && git pull --ff-only && echo deployed: \$(git rev-parse --short HEAD)"
