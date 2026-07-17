# workflow-with-agents

Deterministic, repeatable workflows that can incorporate AI agents as individual steps — the workflow stays in control; agents participate, they don't orchestrate.

Most "agentic" systems hand the agent the wheel: it decides what to do next, what tools to call, and in what order. That's flexible, but it's also unpredictable and hard to secure. This project takes the opposite stance: the workflow defines the steps, their order, and what each step is allowed to touch, and an agent invoked within a step does bounded work — it never decides what happens next.

This repo holds the **specification** and a reference implementation of it, side by side. `SPEC.md` defines what any implementation must satisfy; `workflow/` is one implementation that satisfies it.

- **[SPEC.md](./SPEC.md)** — the normative spec: seven invariants, each with a check and a way to falsify it. 8KB. This is the whole thing.
- **[examples/docker-pipeline.md](./examples/docker-pipeline.md)** — one illustrative, non-normative example of how the invariants could be implemented with Docker.
- **`workflow/`** — the reference implementation, built from the invariants above.

To check an implementation (this one or another) against the spec, follow the [Conformance](./SPEC.md#conformance) section: walk the invariant IDs, run each **Check**, and cite the evidence.

## Running the reference implementation

`workflow/` is a three-step pipeline — clone, agent, diff — that clones a repo,
runs an AI agent against it with instructions you give, and lets you inspect the
resulting `git diff` before deciding what to do next.

Prerequisites: Docker (Desktop, on macOS), an ssh key with clone access to the
target repo, and an `ANTHROPIC_API_KEY`.

Install the `workflow-agent` CLI once, then run it from anywhere — each run
gets its own ID, so multiple runs (different repos, different prompts, or
both) can proceed at once without colliding:

```sh
ssh-add ~/.ssh/<your-key>          # load your key into the host ssh-agent
export ANTHROPIC_API_KEY=...

cd workflow && make install        # symlinks workflow-agent onto PATH

workflow-agent run --repo git@github.com:org/repo.git \
                    --prompt "add input validation to the signup form"

workflow-agent diff  --run-id <id> # printed by `run`; opens a shell to inspect `git diff`
workflow-agent clean --run-id <id> # tears down that run's volume
```

Running several jobs at once with bounded concurrency:
[examples/batch-run.md](./examples/batch-run.md).

The underlying `make workflow`/`make diff`/`make clean` targets still work
directly inside `workflow/` for quick single-run local use without installing
anything — see [workflow/README.md](./workflow/README.md) for those, plus each
step's exact capability grant and the invariant each one satisfies.

## Status

`SPEC.md` is stable. A reference implementation now lives alongside it under `workflow/`.
