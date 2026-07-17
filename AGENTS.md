# Working in this repo

This repo holds the normative **specification**, plus a reference implementation of it under `workflow/`.

- **Implementation code lives under `workflow/`.** It must conform to the invariants in `SPEC.md` and cite invariant IDs at the point where each is enforced (e.g. `# INV-PRIVILEGE-SEPARATION: no agent runtime in this image`), so `grep -rn 'INV-' .` finds every enforcement point.
- **`SPEC.md` is the only normative file, and it MUST stay under 8KB.** It is currently ~8.0KB. If you are adding to it, say what you are removing. Density is the product — the spec earns its keep by being small enough to sit in an agent's context for an entire session.
- **Invariant IDs are permanent.** Never rename, renumber, or reuse one. Implementations cite these IDs in their own source; a rename silently breaks every citation. An invariant that goes away is marked deprecated in place, not deleted.
- **Every invariant needs exactly one MUST sentence, plus a Check and a Falsified-by.** The MUST is the binding assertion; everything else is rationale. If you can't compress it to one testable sentence, it isn't an invariant yet.
- **Implementation choices never enter `SPEC.md`.** Anything naming Docker, Compose, or a specific tool belongs in `examples/`. The exception is the "What's implementation-specific" section, which exists precisely to quarantine them.
- **`examples/` is non-normative.** It MUST NOT introduce a requirement that isn't already in `SPEC.md`.
- **Root `README.md` must stay current with `workflow/`'s actual interface.** When a change under `workflow/` alters how it's installed or invoked (new commands, changed flags, a new entry point), update `README.md` in the same change — don't leave it describing a prior interface.

## Versioning

Tagged `vMAJOR.MINOR.PATCH`. Consumers pin to a tag and vendor `SPEC.md` by URL, so the tag is load-bearing — it's the only thing making a conformance claim falsifiable.

- **MAJOR** — an invariant added, removed, or materially changed. Downstream conformance may break.
- **MINOR** — a new example, a clarification, or an implementation change under `workflow/` that doesn't change what conforms.
- **PATCH** — wording.
