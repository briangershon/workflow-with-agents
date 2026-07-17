# INV-PRIVILEGE-SEPARATION: no ssh keys, no git push credentials, no ssh-agent
# mount in this image or granted to this step (see docker-compose.yml). This
# step runs an agent, so it holds no consequential credential.
FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g @anthropic-ai/claude-code

COPY run-agent.sh /usr/local/bin/run-agent.sh
RUN chmod +x /usr/local/bin/run-agent.sh

ENTRYPOINT ["/usr/local/bin/run-agent.sh"]
