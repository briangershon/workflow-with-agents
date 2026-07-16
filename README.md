# workflow-with-agents

Deterministic, repeatable workflows that can incorporate AI agents as individual steps — the workflow stays in control; agents participate, they don't orchestrate.

Most "agentic" systems hand the agent the wheel: it decides what to do next, what tools to call, and in what order. That's flexible, but it's also unpredictable and hard to secure. This project takes the opposite stance: the workflow defines the steps, their order, and what each step is allowed to touch, and an agent invoked within a step does bounded work — it never decides what happens next.

This repo holds the **specification** and a reference implementation of it, side by side. `SPEC.md` defines what any implementation must satisfy; `workflow/` is one implementation that satisfies it.

- **[SPEC.md](./SPEC.md)** — the normative spec: seven invariants, each with a check and a way to falsify it. 8KB. This is the whole thing.
- **[examples/docker-pipeline.md](./examples/docker-pipeline.md)** — one illustrative, non-normative example of how the invariants could be implemented with Docker.
- **`workflow/`** — the reference implementation, built from the invariants above.

To check an implementation (this one or another) against the spec, follow the [Conformance](./SPEC.md#conformance) section: walk the invariant IDs, run each **Check**, and cite the evidence.

## Versioning

Tagged `vMAJOR.MINOR.PATCH`. Pin to a tag.

- **MAJOR** — an invariant added, removed, or materially changed. Your conformance may break.
- **MINOR** — a new example, a clarification, or an implementation change under `workflow/`. Conformance unaffected.
- **PATCH** — wording.

## Status

`SPEC.md` is stable. A reference implementation now lives alongside it under `workflow/`.
