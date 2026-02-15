# ai-dev-kit Docker Sandbox template
# Requires: Docker Desktop 4.50+ with Docker Sandboxes enabled
#
# Build:  docker build -t ai-dev-kit-sandbox:latest .sandbox/
# Use:    docker sandbox run --load-local-template -t ai-dev-kit-sandbox:latest claude .

FROM docker/sandbox-templates:claude-code

USER root

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-pip \
    jq \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Agent workflow tools
RUN npm install -g @th0rgal/ralph-wiggum @beads/bd

# Switch back to agent user (required by Docker Sandboxes)
USER agent

# Default git identity — override in your fork or via env vars
RUN git config --global user.name "AI Agent" && \
    git config --global user.email "agent@ai-dev-kit"
