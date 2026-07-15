# Principles

These are the durable ideas behind `workflow-with-agents` — independent of Docker, Compose, or whatever tooling happens to implement them today. If the underlying technology changes, a redesign that satisfies these invariants is still "this project." One that doesn't, isn't, no matter what tools it uses.

## Premise

Most "agentic" systems hand the agent the wheel: it decides what to do next, what tools to call, and in what order. That's flexible, but unpredictable and hard to secure — an agent that *can* decide to push to `main` is an agent that eventually will, intentionally or not.

This project takes the opposite stance: the workflow stays in control, and agents participate as bounded steps within it. They don't orchestrate.

## Invariants

Any implementation of this project — present or future — should satisfy all of these:

1. **The workflow is the source of truth.** Step order and each step's allowed access are defined outside the agent, ahead of time. An agent invoked inside a step does bounded work; it never decides what happens next in the workflow.

2. **Runs are deterministic and repeatable.** The same workflow definition, run twice, executes the same steps in the same order with the same access grants — regardless of what an agent inside a step chooses to do internally.

3. **Least privilege per step.** Every step gets exactly the capabilities — tools, environment, network access, credentials — that its one job requires, and nothing more.

4. **Isolation between steps.** Each step runs in its own sandboxed execution context. A compromised or misbehaving step is bounded by what that one step was granted; it can't reach into another step's capabilities.

5. **One explicit shared-state channel.** Steps don't pass state to each other ad hoc — through arbitrary network calls, manual file shuffling, or hidden side channels. They share a single, common, explicit state substrate that every step reads from and writes to, so data flow through the workflow stays inspectable end to end.

6. **Privilege separation between agentic and consequential steps.** A step that runs an agent never holds the credentials for an irreversible or high-trust action (publishing, pushing, deleting, spending). The step that holds those credentials doesn't run an agent.

7. **Workflows are arbitrary compositions of scoped steps.** The number and shape of steps is not fixed. Adding capability to a workflow means adding a new, narrowly-scoped step — not widening an existing step's privileges.

## What's implementation-specific (not a principle)

The following are choices this project currently makes to satisfy the invariants above — they are not the invariants themselves, and a future version is free to replace any of them:

- Using Docker containers as the isolation boundary between steps.
- Using a Docker named volume as the shared-state channel.
- Using Docker Compose as the composition layer.
- Using a Makefile as the run interface.

Swap any of these for whatever is current — a different sandbox technology, a different state store, a different orchestrator — as long as the invariants still hold.

## Self-check for a redesign

Before calling a new implementation "this project," it should be able to answer yes to all of:

- [ ] Is the sequence and permission set of steps defined outside of, and prior to, any agent's own decision-making?
- [ ] Does running the same workflow definition twice produce the same steps, same order, same access grants?
- [ ] Does every step have documented, minimal access — and nothing broader "just in case"?
- [ ] Is each step isolated such that a compromised step is contained to only what it was granted?
- [ ] Is there exactly one explicit, inspectable channel through which steps share state?
- [ ] Is it structurally impossible for a step that runs an agent to also hold credentials for an irreversible action?
- [ ] Can new capability be added as a new scoped step, without widening an existing step's access?

If any answer is no, it's a different kind of system, not a new implementation of this one.
