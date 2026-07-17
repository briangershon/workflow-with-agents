# workflow-with-agents — specification

These are the durable, binding criteria for `workflow-with-agents` — independent of Docker, Compose, or whatever tooling implements them today. An implementation that satisfies these invariants is "this project." One that doesn't, isn't.

Each invariant states its requirement in one **MUST** sentence. Everything else is rationale.

## Premise

Most "agentic" systems hand the agent the wheel: it decides what to do next, what tools to call, and in what order. That's flexible, but unpredictable and hard to secure — an agent that *can* decide to push to `main` is an agent that eventually will, intentionally or not.

This project takes the opposite stance: the workflow stays in control, and agents participate as bounded steps within it. They don't orchestrate.

## Non-goals

This project is **not**:

- a general-purpose CI/CD system, scheduler, or DAG engine
- an agent framework, or a way to make agents better at their job
- a hosted service or control plane
- an attempt to constrain what an agent *thinks* — only what it *can reach*

That last one is the threat model: capability containment, not alignment. An implementation that grows the others is a different project.

## Glossary

- **Step** — one unit of the workflow, executing in its own isolated context with its own capability grant. The unit of both isolation and privilege.
- **Workflow** — an ordered composition of steps, defined ahead of time, outside any agent.
- **Capability** — anything a step can reach: tools, binaries, environment variables, credentials, network egress, mounted state. *Not* Linux `capabilities(7)` / `cap_add`.
- **Capability grant** — the exact set of capabilities given to one step, declared in the workflow definition.
- **Shared-state channel** — the single substrate every step reads from and writes to in order to pass state. The only sanctioned way data crosses a step boundary.
- **Agentic step** — a step that invokes an AI agent: one whose exact actions are decided at run time by a model.
- **Consequential step** — a step performing an irreversible or high-trust action: publishing, pushing, deleting, spending, notifying externally. A **consequential credential** authorizes one.

## Invariants

Every implementation must satisfy all of these.

### INV-WORKFLOW-AUTHORITY — The workflow is the source of truth

Step order and each step's capability grant **MUST** be defined outside the agent, ahead of time.

An agent invoked inside a step does bounded work. It never decides what happens next in the workflow.

**Check:** Locate where step order and capability grants are defined. Confirm nothing an agent produces at run time feeds back into either.
**Falsified by:** an agent's output selecting the next step, or determining what any step may access.

### INV-DETERMINISM — Runs are deterministic and repeatable

The same workflow definition, run twice, **MUST** execute the same steps in the same order with the same capability grants.

Determinism is a property of the workflow, not of the agent.

**Check:** Run one workflow definition twice. Compare the sequence of steps executed and the grant each received.
**Falsified by:** any run-time input — agent output, wall-clock time, network state — changing which steps run, their order, or their grants.

### INV-LEAST-PRIVILEGE — Every step gets exactly what its one job needs

Every step **MUST** receive exactly the capabilities its one job requires, and nothing more.

**Check:** For each step, enumerate its granted capabilities and name the part of its job that requires each one. Every capability has a named justification.
**Falsified by:** a capability no part of the step's job uses — a credential kept "for convenience," broad network egress where one host would do, a tool the step never invokes.

### INV-ISOLATION — Steps are isolated from each other

Each step **MUST** run in its own sandboxed execution context, able to reach nothing granted to another step.

**Check:** For each step, determine what it can reach outside its own grant. The answer is nothing but the shared-state channel.
**Falsified by:** two steps sharing an execution context; a step reading another's environment or credentials; a mount that reaches outside the sandbox.

### INV-SHARED-STATE — One explicit shared-state channel

Steps **MUST** pass state through exactly one explicit, inspectable substrate, and through no other.

Ad-hoc state passing makes data flow through the workflow uninspectable end to end.

**Check:** Enumerate every mechanism by which data crosses a step boundary. Exactly one of them is the shared-state channel.
**Falsified by:** any second channel — an inter-step network call, a host bind mount, an environment variable carrying a payload, an external bucket.

### INV-NEUTRAL-HANDOFF — A step's handoff must not presume who reads it next

A step **MUST NOT** leave the shared-state channel in a form only a specific later identity or grant can consume.

Ownership, permission bits, and locks cross the step boundary too, not just file contents — presuming a specific reader couples a step to that reader's identity, the mirror image of `INV-ISOLATION`.

**Check:** For each step, confirm what it leaves on the shared channel — ownership, permissions, locks — needs no specific identity to consume.
**Falsified by:** an ownership or permission change that blocks a later, correctly-scoped step from reading or acting on the shared channel.

### INV-PRIVILEGE-SEPARATION — Agentic steps hold no consequential credentials

An agentic step **MUST NOT** hold a consequential credential, and a step holding one **MUST NOT** run an agent.

The separation is structural — the credential is *absent* — not procedural. An agent merely instructed to avoid a credential it can reach does not satisfy this.

**Check:** For each step, determine whether it invokes an agent and whether it holds any consequential credential. No step is both.
**Falsified by:** an agentic step with a push token in its environment, secrets, or mounts — or an agent runtime present in the image of a step that publishes.

### INV-COMPOSITION — New capability means a new step

Adding capability to a workflow **MUST** take the form of a new, narrowly-scoped step — never a widening of an existing step's grant.

**Check:** Review how each step's grant has changed over time. Grants narrow or stay flat; new capability arrives as new steps.
**Falsified by:** a step whose grant grew to cover a job it didn't originally have.

## What's implementation-specific (not a principle)

Choices this project currently makes to satisfy the invariants above — not the invariants themselves. A future version may replace any of them; the `because` is what a replacement must preserve.

- **Docker containers as the isolation boundary** — because a container gives each step its own filesystem, process space, and environment, with a per-step declaration of what enters it (`INV-ISOLATION`).
- **A Docker named volume as the shared-state channel** — because it is singular, mounted identically into every step, and inspectable from outside the steps without leaving the machine (`INV-SHARED-STATE`, `INV-NEUTRAL-HANDOFF`).
- **Docker Compose as the composition layer** — because it declares every step and its grant in one file, outside any agent, in version control (`INV-WORKFLOW-AUTHORITY`).
- **A Makefile as the run interface** — because it fixes step order in version-controlled text rather than in an operator's memory (`INV-DETERMINISM`).

## Conformance

To check an implementation, walk the invariant IDs in order. For each one:

1. Run its **Check** and record the evidence — file and line — that answers it.
2. Attempt its **Falsified by**: go looking for the specific thing that would disprove it.

An invariant with no evidence cited is unverified, not passing.

Each **Check** says what to look for, not how. The *how* is technology-specific and belongs with the implementation, not this spec.

If any invariant is falsified, it's a different kind of system — not a new implementation of this one.
