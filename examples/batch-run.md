# Example: running many jobs at once

One possible way to run several (repo, change) jobs at once using
[`workflow/bin/workflow-agent`](../workflow/bin/workflow-agent).

This is **illustrative and non-normative** — a composition pattern layered on
top of the reference implementation under [`workflow/`](../workflow). It
cannot introduce a requirement that isn't already in the spec.

## Why no built-in batch mode

`workflow-agent run` is deliberately single-job: one repo, one prompt, one
call. Each call gets its own run ID and its own Docker Compose project name,
which namespaces its shared volume separately from every other run
(`workflow-agent-<id>_repo`). That per-run isolation is what makes it safe to
launch several calls at once in the first place — running many jobs is just
running that one primitive several times, with ordinary shell tools handling
the fan-out.

## Bounded-concurrency batch

```sh
# jobs.csv: one "repo_url,prompt" pair per line
git@github.com:org/service-a.git,add input validation to the signup form
git@github.com:org/service-b.git,upgrade the logging library
git@github.com:org/service-c.git,fix the flaky retry test

while IFS=, read -r repo prompt; do
  printf 'workflow-agent run --repo %q --prompt %q\n' "$repo" "$prompt"
done < jobs.csv | xargs -P4 -I{} sh -c '{}'
```

`-P4` caps concurrency at four jobs at a time — adjust to whatever your
machine and Docker daemon can comfortably run. Each job prints its own run ID
on completion, which you then use to inspect and clean up:

```sh
workflow-agent diff  --run-id <id>
workflow-agent clean --run-id <id>
```

Nothing here changes what any one step can reach — it's the same fixed
`clone` → `agent` pipeline, run several times over, each time with its own
isolated shared-state channel (`INV-SHARED-STATE`, `INV-ISOLATION`).
