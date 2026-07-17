#!/bin/sh
set -eu

if [ -z "${REPO_URL:-}" ]; then
  echo "REPO_URL is required" >&2
  exit 1
fi

# INV-SHARED-STATE / determinism of this step's own effect: never build a clone
# on top of a previous run's leftovers.
rm -rf /repo/.git /repo/..?* /repo/.[!.]* /repo/* 2>/dev/null || true

# INV-PRIVILEGE-SEPARATION: uses the ssh-agent forwarded from the host (loaded
# via `ssh-add` before this step ran) instead of a key baked into the image or
# volume. accept-new avoids hanging on an interactive host-key prompt.
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

git clone "$REPO_URL" /repo
