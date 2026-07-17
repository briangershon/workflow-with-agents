# `workflow/` — reference implementation

A three-step pipeline: **clone → agent → diff**. Point it at a repo and an
instruction string; an agent makes the change inside an isolated container; you
inspect the result in a third container before deciding what to do with it. No
publish/push step yet — see `SPEC.md`'s `INV-COMPOSITION`: that's new capability,
and arrives as its own future step, not by widening one of these three.

## Prerequisites

- Docker Desktop (this uses its macOS ssh-agent forwarding at
  `/run/host-services/ssh-auth.sock`; on Linux, point that same compose mount at
  `$SSH_AUTH_SOCK` instead).
- An ssh key with clone access to the target repo, loaded into your host
  ssh-agent.
- An `ANTHROPIC_API_KEY`.

## Usage

```sh
ssh-add ~/.ssh/<your-key>          # load your key into the host ssh-agent
cd workflow
export ANTHROPIC_API_KEY=...

make workflow \
  REPO_URL=git@github.com:org/repo.git \
  PROMPT="add input validation to the signup form"

make diff                          # opens a shell on the shared volume; run `git diff`

make clean                         # tears down the named volume before the next run
```

`make workflow` runs `clone` then `agent`, in that fixed order (`INV-DETERMINISM`,
`INV-WORKFLOW-AUTHORITY`). Each can also be run on its own: `make clone
REPO_URL=...`, `make agent PROMPT=...`.

## Installing as a CLI

`make workflow` is fine for one run at a time in one checkout, but it shares a
single hardcoded volume name (`repo`) — a second concurrent invocation would
collide with the first. `bin/workflow-agent` wraps the same steps with a
unique Compose project name per invocation, so any number of runs — different
repos, different prompts, or both — can proceed at once without interfering.

Install it onto `PATH`:

```sh
make install                  # symlinks bin/workflow-agent into /usr/local/bin
make install PREFIX=~/.local  # or any other prefix
```

Then, from anywhere:

```sh
workflow-agent run --repo git@github.com:org/repo.git \
                    --prompt "add input validation to the signup form"
# Run complete. Run ID: 20260717151530-4821
#   Inspect:  workflow-agent diff  --run-id 20260717151530-4821
#   Clean up: workflow-agent clean --run-id 20260717151530-4821

workflow-agent diff  --run-id 20260717151530-4821
workflow-agent clean --run-id 20260717151530-4821
```

Each run ID becomes the Docker Compose project name (`workflow-agent-<id>`),
which namespaces that run's `repo` volume as `workflow-agent-<id>_repo` —
Compose does this automatically, so `docker-compose.yml` itself needed no
changes. This is an implementation-specific choice, not a spec requirement:
it doesn't add capability or change any step's grant, it only keeps
`INV-SHARED-STATE`'s one channel from being accidentally shared *across* runs
the way it's deliberately shared *within* one run.

`make uninstall` (optionally with the same `PREFIX`) removes the symlink.

To run many jobs at once with bounded concurrency, see
`../examples/batch-run.md`.

## Steps and their grants

| step  | holds                                   | runs an agent | INV citations |
|-------|------------------------------------------|:---:|---|
| clone | ssh-agent socket, `REPO_URL`             | no  | `INV-LEAST-PRIVILEGE`, `INV-PRIVILEGE-SEPARATION` |
| agent | `ANTHROPIC_API_KEY`, `PROMPT`, network   | yes | `INV-ISOLATION`, `INV-PRIVILEGE-SEPARATION` |
| diff  | nothing but the shared volume            | no  | `INV-ISOLATION`, `INV-LEAST-PRIVILEGE` |

All three mount the same named volume (`repo`) — the one shared-state channel
(`INV-SHARED-STATE`) — and nothing else crosses a step boundary: `agent` never
sees the ssh-agent socket, and neither `clone` nor `diff` ever see the API key.

The `ANTHROPIC_API_KEY` is the credential the agent step's one job structurally
requires (calling the LLM); it is not a "consequential credential" in the spec's
sense (no push/delete/publish/notify power), so `INV-PRIVILEGE-SEPARATION` is
satisfied by this step holding it while running an agent.

Known limitation: the forwarded ssh-agent exposes whatever key(s) you've loaded,
which may carry more than read-only clone access. Scoping `clone` down to a
read-only deploy key is a reasonable future step, not solved here.

To verify grants match what's claimed: `grep -rn 'INV-' .` from this directory
surfaces every enforcement point, and `docker compose config` shows exactly what
volumes/env each service receives.
