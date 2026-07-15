# workflow-with-agents

Deterministic, repeatable workflows that can incorporate AI agents as individual steps — the workflow stays in control; agents participate, they don't orchestrate.

## Objectives

Most "agentic" systems hand the agent the wheel: it decides what to do next, what tools to call, and in what order. That's flexible, but it's also unpredictable and hard to secure — an agent that can decide to push to `main` is an agent that eventually will, intentionally or not.

This project takes the opposite stance:

- **The workflow is the source of truth.** It defines the steps, their order, and what each step is allowed to touch. Agents are invoked *within* a step to do a bounded piece of work, not to decide what happens next.
- **Runs are deterministic and repeatable.** The same workflow definition, run twice, executes the same steps in the same order with the same access controls — regardless of what an agent inside a step chooses to do internally.
- **Least privilege per step.** Every step gets exactly the tools, environment variables, network access, and credentials it needs and nothing more. A step that clones a repo doesn't get push credentials. A step that runs an agent doesn't get to publish. A step that publishes doesn't run an agent.

## Core concepts

- **Steps as isolated containers** — each step in a workflow is its own Docker container (its own Dockerfile), scoped to the minimum tools, env vars, network access, and credentials that step requires. Splitting responsibilities this way means a compromised or misbehaving agent step never has more capability than that one step was granted.
- **A shared named volume as the common filesystem** — steps don't share state through the network or by passing files around manually. They share a single Docker named volume, mounted into each step's container, that acts as the common filesystem for the whole workflow run.
- **Docker Compose as the composition layer** — `docker-compose.yml` sits at the center, defining the shared volume and the services (steps) that mount it. Compose is what makes "many small isolated containers" feel like one coherent workflow.
- **A Makefile as the run interface** — a `Makefile` provides simple, memorable targets to run an individual step or an entire workflow (e.g. `make clone`, `make agent`, `make publish`, `make workflow`), wrapping the underlying `docker compose run` calls.
- **A workflow is a composition of steps** — the number and shape of steps is arbitrary. A workflow is just an ordered sequence of steps, each with its own container and its own scoped access, all passing state through the shared volume.

## Example workflow: coding pipeline

One example of this pattern — not the only shape a workflow can take — is a pipeline that uses an agent to make a code change:

1. **clone** — clones the target git repo into the shared volume. No agent, no git push credentials. Its only job is to get code onto the volume.
2. **agent** — mounts the shared volume, runs an AI agent, and has network access so the agent can do its work (e.g. read docs, call APIs). It can modify files on the volume but has no git push credentials.
3. **publish** — mounts the shared volume, verifies the changes (tests, lint, review), and holds the git push credentials needed to commit and push. It does not run an agent.

Because each step is a separate container with separate scoped access, the only place credentials to push code exist is in the one step whose entire job is publishing — the step that runs the agent never has them.

Other workflows might have more or fewer steps (e.g. a build step, a security-scan step, a notification step) — the pattern is general: decompose the workflow into steps, give each step only what it needs, and let the shared volume carry state between them.

## Proposed initial layout

```
workflow-with-agents/
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

- **`docker-compose.yml`** — defines the shared named volume and one service per step, each mounting that volume and declaring only the environment variables / network access it needs.
- **`Makefile`** — exposes one target per step (thin wrappers around `docker compose run <step>`), plus a target that runs a full workflow end to end.
- **`steps/<name>/`** — each step's own Dockerfile and any scripts specific to that step. Steps are added by dropping in a new directory here and wiring it into `docker-compose.yml` and the `Makefile`.

## Status

Early-stage — this README defines the direction and initial shape of the project before any of the Dockerfiles, Compose file, or Makefile exist.
