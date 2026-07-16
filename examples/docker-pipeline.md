# Example: a Docker-based pipeline

One possible concrete implementation of the invariants in [SPEC.md](../SPEC.md), using Docker.

This is **illustrative and non-normative** — a reference for what the implementation under [`workflow/`](../workflow) looks like. It cannot introduce a requirement that isn't already in the spec.

## A Docker-based approach

- **Steps as isolated containers** — each step is its own Docker container with its own Dockerfile, scoped to the minimum tools, environment variables, network access, and credentials that step requires. A compromised or misbehaving agent step never has more capability than that one step was granted. (`INV-ISOLATION`, `INV-LEAST-PRIVILEGE`)
- **A shared named volume as the common filesystem** — steps don't share state through the network or by passing files around manually. They share a single Docker named volume, mounted into each step's container, acting as the common filesystem for the whole workflow run. It is the only thing that crosses a step boundary. (`INV-SHARED-STATE`)
- **Docker Compose as the composition layer** — `docker-compose.yml` sits at the center, defining the shared volume and the services (steps) that mount it, each declaring only the environment and network access it needs. Compose is what makes "many small isolated containers" feel like one coherent workflow, and it puts every capability grant in one file, in version control, outside any agent. (`INV-WORKFLOW-AUTHORITY`)
- **A Makefile as the run interface** — simple, memorable targets to run an individual step or an entire workflow (e.g. `make clone`, `make agent`, `make publish`, `make workflow`), wrapping the underlying `docker compose run` calls. Step order lives in the Makefile, so the same target runs the same steps every time. (`INV-DETERMINISM`)
- **A workflow is a composition of steps** — the number and shape of steps is arbitrary: an ordered sequence, each with its own container and its own scoped access, all passing state through the shared volume. (`INV-COMPOSITION`)

## Example workflow: coding pipeline

One example of this pattern — not the only shape a workflow can take — is a pipeline that uses an agent to make a code change:

1. **clone** — clones the target git repo into the shared volume. No agent, no git push credentials. Its only job is to get code onto the volume. (`INV-LEAST-PRIVILEGE`)
2. **agent** — mounts the shared volume, runs an AI agent, and has network access so the agent can do its work (read docs, call APIs). It can modify files on the volume but holds no git push credentials. An agentic step. (`INV-PRIVILEGE-SEPARATION`)
3. **publish** — mounts the shared volume, verifies the changes (tests, lint, review), and holds the git push credentials needed to commit and push. It does not run an agent. A consequential step. (`INV-PRIVILEGE-SEPARATION`)

Because each step is a separate container with separate scoped access, the only place credentials to push code exist is in the one step whose entire job is publishing. The step that runs the agent never has them — not because it's told not to use them, but because they aren't there.

Other workflows might have more or fewer steps (a build step, a security-scan step, a notification step). The pattern is general: decompose the workflow into steps, give each step only what it needs, and let the shared volume carry state between them.

## Proposed initial layout

```
workflow/
  docker-compose.yml
  Makefile
  steps/
    clone/
      Dockerfile
    agent/
      Dockerfile
    publish/
      Dockerfile
```

- **`workflow/docker-compose.yml`** — defines the shared named volume and one service per step, each mounting that volume and declaring only the environment variables and network access it needs.
- **`workflow/Makefile`** — one target per step (thin wrappers around `docker compose run <step>`), plus a target that runs a full workflow end to end.
- **`workflow/steps/<name>/`** — each step's own Dockerfile and any scripts specific to it. Steps are added by dropping in a new directory and wiring it into `docker-compose.yml` and the `Makefile` — never by widening an existing step. (`INV-COMPOSITION`)
