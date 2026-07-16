# workflow-with-agents

Deterministic, repeatable workflows that can incorporate AI agents as individual steps — the workflow stays in control; agents participate, they don't orchestrate.

Most "agentic" systems hand the agent the wheel: it decides what to do next, what tools to call, and in what order. That's flexible, but it's also unpredictable and hard to secure. This project takes the opposite stance: the workflow defines the steps, their order, and what each step is allowed to touch, and an agent invoked within a step does bounded work — it never decides what happens next.

This repo is the **specification**, not the implementation. It defines what any implementation must satisfy; you build the implementation elsewhere, from these invariants.

- **[SPEC.md](./SPEC.md)** — the normative spec: seven invariants, each with a check and a way to falsify it. 8KB. This is the whole thing.
- **[examples/docker-pipeline.md](./examples/docker-pipeline.md)** — one illustrative, non-normative example of how the invariants could be implemented with Docker.

## Using these principles in your project

Vendor the spec into your implementation repo, pinned to a tag:

```bash
mkdir -p spec && curl -fsSL \
  https://raw.githubusercontent.com/briangershon/workflow-with-agents/v0.2.0/SPEC.md \
  -o spec/workflow-with-agents.md
```

> **Not live yet.** This repo is private and `v0.2.0` isn't tagged, so the command above 404s. It describes the intended path. Until the repo is public and tagged, add `-H "Authorization: Bearer $(gh auth token)"` to the curl, or copy `SPEC.md` in by hand.

Then copy [`templates/AGENTS.md`](./templates/AGENTS.md) into your repo as `AGENTS.md` and fill in its placeholders. That file is what points your coding agent at the vendored spec and keeps the invariants in front of it.

Vendor rather than fetching the spec at run time. Pinning to a tag is what makes a build reproducible and a conformance claim falsifiable — and when you bump the pin, the change arrives as a reviewable diff instead of shifting under you silently.

To check an implementation against the spec, follow the [Conformance](./SPEC.md#conformance) section: walk the invariant IDs, run each **Check**, and cite the evidence.

## Versioning

Tagged `vMAJOR.MINOR.PATCH`. Pin to a tag.

- **MAJOR** — an invariant added, removed, or materially changed. Your conformance may break.
- **MINOR** — a new example, template, or clarification. Conformance unaffected.
- **PATCH** — wording.

## Status

Specification-only, by design. No Dockerfiles, Compose file, Makefile, or other code exist here, and none will — `examples/` describes an implementation in prose rather than shipping one. The point is to find out whether an agent given only these invariants derives the right design, which you can't learn by handing it the answer.
