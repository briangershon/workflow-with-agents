<!-- Drop this into your implementation repo as AGENTS.md, or merge it into an existing one.
     Replace the <ANGLE-BRACKET> placeholders, then delete this comment.
     Note: while the spec repo is private and untagged, the curl below needs
     -H "Authorization: Bearer $(gh auth token)" and a ref that exists. -->

## Specification

This repo implements [`workflow-with-agents`](https://github.com/briangershon/workflow-with-agents). The spec is vendored at `spec/workflow-with-agents.md`, pinned to **v0.2.0**.

**Read it in full before designing or changing any step, capability grant, or workflow definition.** It is 8KB — read it, don't summarize it. The bullets below are a tripwire to make you go read it, not a substitute for it.

### The ones that get violated first

- Step order and capability grants live in `<WORKFLOW-DEFINITION-FILE>`. An agent never decides them. (`INV-WORKFLOW-AUTHORITY`)
- A step that runs an agent never holds credentials for an irreversible action — publishing, pushing, deleting, spending. The separation is structural: the credential is *absent*, not merely discouraged. (`INV-PRIVILEGE-SEPARATION`)
- Steps pass state only through `<SHARED-STATE-CHANNEL>`. Nothing else crosses a step boundary. (`INV-SHARED-STATE`)
- New capability means a new scoped step — never a widening of an existing step's grant. (`INV-COMPOSITION`)

### Citing invariants

Cite the invariant ID at the point where it's enforced, so `grep -rn 'INV-' .` returns every enforcement point in the repo:

```yaml
publish:
  build: ./steps/publish        # INV-PRIVILEGE-SEPARATION: no agent runtime in this image
  environment:
    - GIT_PUSH_TOKEN            # consequential step: holds the credential, runs no agent
```

### Refreshing the spec

```bash
curl -fsSL https://raw.githubusercontent.com/briangershon/workflow-with-agents/v0.2.0/SPEC.md \
  -o spec/workflow-with-agents.md
```

Bumping the pinned version lands as a reviewable diff — read what changed before accepting it. A MAJOR bump means an invariant was added, removed, or materially changed, and your conformance may no longer hold.
