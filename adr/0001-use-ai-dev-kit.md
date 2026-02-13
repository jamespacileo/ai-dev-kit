# 0001. Use ai-dev-kit as Project Starter Template

Date: 2026-02-13
Status: Accepted

## Context

New projects need consistent scaffolding for AI-assisted development. Without a standard template, each project reinvents: task tracking, autonomous agent loops, CI/CD pipelines, security scanning, code quality tools, and agent instructions. This leads to inconsistent workflows and wasted setup time.

## Decision

Adopt ai-dev-kit as the standard template for all new projects. The template includes:

- **Task tracking**: Beads (`bd`) with dependency-aware task graphs
- **Autonomous loops**: Ralph Wiggum for iterative agent execution
- **Planning**: Superpowers for structured brainstorm-plan-execute methodology
- **Custom skills**: `/decompose`, `/sprint`, `/review-sprint`, `/status`, `/create-adr`
- **MCP servers**: Sequential Thinking, Context7, Memory, Playwright, Repomix
- **Code quality**: Biome (JS/TS/CSS linting and formatting)
- **Security**: Gitleaks (pre-commit secret scanning) + Semgrep (CI SAST)
- **CI/CD**: GitHub Actions for lint, test, security, and automated releases
- **Environment**: mise for tool version pinning
- **Git conventions**: Conventional Commits via commitlint
- **Documentation**: Architecture Decision Records (ADRs)
- **Dependencies**: Renovate for automated updates

## Alternatives Considered

- **No template**: Each project configures tools from scratch. Rejected due to inconsistency and setup overhead.
- **Existing templates** (serpro69/claude-starter-kit, etc.): Evaluated but lacked the Beads + Ralph + Superpowers integration and opinionated CI/CD pipeline.
- **Framework-specific starters** (create-next-app, etc.): Too narrow for a generalist template.

## Consequences

- All projects start with a consistent, battle-tested toolchain
- New contributors can onboard faster with familiar structure
- Biome is JS/TS/CSS only — projects using other languages will need to swap or supplement the linter
- The template is opinionated — teams may need to remove tools they don't use
- MCP servers add startup overhead — disable unused ones in `.claude/settings.json`
