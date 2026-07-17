# INV-WORKFLOW-AUTHORITY / INV-DETERMINISM: step order is fixed here, in
# version-controlled text, not in an operator's memory or an agent's output.

export REPO_URL
export PROMPT

.PHONY: clone agent diff workflow clean

clone:
	@test -n "$(REPO_URL)" || (echo "REPO_URL is required, e.g. make clone REPO_URL=git@github.com:org/repo.git" && exit 1)
	docker compose run --rm clone

agent:
	@test -n "$(PROMPT)" || (echo "PROMPT is required, e.g. make agent PROMPT=\"add input validation\"" && exit 1)
	docker compose run --rm agent

diff:
	docker compose run --rm diff

# The full pipeline, in fixed order: clone always runs before agent.
workflow: clone agent
	@echo "Workflow complete. Run 'make diff' to inspect the changes."

clean:
	docker compose down -v
