# workflow-with-agents

Deterministic, repeatable workflows that can incorporate AI agents as individual steps — the workflow stays in control; agents participate, they don't orchestrate.

Most "agentic" systems hand the agent the wheel: it decides what to do next, what tools to call, and in what order. That's flexible, but it's also unpredictable and hard to secure. This project takes the opposite stance: the workflow defines the steps, their order, and what each step is allowed to touch, and an agent invoked within a step does bounded work — it never decides what happens next.

## Learn more

- **[docs/PRINCIPLES.md](./docs/PRINCIPLES.md)** — the durable design principles this project follows, independent of any particular implementation.
- **[docs/IMPLEMENTATION-EXAMPLE.md](./docs/IMPLEMENTATION-EXAMPLE.md)** — one illustrative example of how those principles could be implemented (using Docker), including an example workflow and proposed file layout.

## Status

Early-stage and docs-only — this repo defines the direction and principles for the project. No Dockerfiles, Compose file, Makefile, or other code exist yet.
