# Working in this repo

You are editing a **specification**. This repo contains no implementation and never will.

- **Do not add an implementation.** No Dockerfiles, no `docker-compose.yml`, no Makefile, no scripts. `examples/` describes them in prose on purpose: this repo is the input to an experiment in whether an agent can derive a design from invariants alone, and shipping the answer key destroys the result being measured.
- **`SPEC.md` is the only normative file, and it MUST stay under 8KB.** It is currently ~8.0KB. If you are adding to it, say what you are removing. Density is the product — the spec earns its keep by being small enough to sit in an agent's context for an entire session.
- **Invariant IDs are permanent.** Never rename, renumber, or reuse one. Implementations cite these IDs in their own source; a rename silently breaks every citation. An invariant that goes away is marked deprecated in place, not deleted.
- **Every invariant needs exactly one MUST sentence, plus a Check and a Falsified-by.** The MUST is the binding assertion; everything else is rationale. If you can't compress it to one testable sentence, it isn't an invariant yet.
- **Implementation choices never enter `SPEC.md`.** Anything naming Docker, Compose, or a specific tool belongs in `examples/`. The exception is the "What's implementation-specific" section, which exists precisely to quarantine them.
- **`examples/` and `templates/` are non-normative.** They MUST NOT introduce a requirement that isn't already in `SPEC.md`.

## Versioning

Tagged `vMAJOR.MINOR.PATCH`. Consumers pin to a tag and vendor `SPEC.md` by URL, so the tag is load-bearing — it's the only thing making a conformance claim falsifiable.

- **MAJOR** — an invariant added, removed, or materially changed. Downstream conformance may break.
- **MINOR** — a new example, a new template, a clarification that doesn't change what conforms.
- **PATCH** — wording.
