# INV-LEAST-PRIVILEGE: read-only inspection needs nothing beyond git, an editor,
# and a shell. No credentials, no agent runtime.
FROM alpine:3.20

RUN apk add --no-cache git vim

# The agent step chowns the volume to a non-root uid (see run-agent.sh) so it
# can drop root before invoking claude, and that ownership persists on the
# named volume. This step runs as root and would otherwise have git refuse to
# recognize a repo it doesn't own (git's "dubious ownership" check) — root
# already has unrestricted OS-level access to every file here regardless of
# owner, so this only waives git's own opt-in check, not a real permission
# boundary.
RUN git config --system --add safe.directory '*'

WORKDIR /repo
CMD ["sh"]
