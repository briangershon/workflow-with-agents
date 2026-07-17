#!/bin/sh
set -eu

if [ -z "${PROMPT:-}" ]; then
  echo "PROMPT is required" >&2
  exit 1
fi

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ANTHROPIC_API_KEY is required" >&2
  exit 1
fi

# claude --dangerously-skip-permissions refuses to run as root. The container's
# default user is root (so this entrypoint can chown the volume below); drop to
# the image's unprivileged `node` user for the actual agent invocation. `su`
# (without -m) sets HOME to node's own home dir while still passing PROMPT,
# ANTHROPIC_API_KEY, and PATH through from this process's environment.
#
# This chown is not transient: it persists on the named volume for whatever
# step reads it next. Any later step that runs git as root (e.g. diff) needs
# `git config --system --add safe.directory '*'` in its own image, or git will
# refuse to recognize the repo it doesn't own.
chown -R node:node /repo

# INV-WORKFLOW-AUTHORITY: this step does bounded work on the instructions it was
# given; it never decides what the next step in the workflow is.
exec su node -c 'cd /repo && claude --model claude-sonnet-5 --dangerously-skip-permissions -p "$PROMPT"'
