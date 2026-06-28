# Ruflo — Claude Code Configuration

## Rules

- Do what has been asked; nothing more, nothing less
- NEVER create files unless absolutely necessary — prefer editing existing files
- NEVER create documentation files unless explicitly requested
- NEVER save working files or tests to root — use `/src`, `/tests`, `/docs`, `/config`, `/scripts`
- ALWAYS read a file before editing it
- NEVER commit secrets, credentials, or .env files
- NEVER add a `Co-Authored-By` trailer to user commits unless this project's `.claude/settings.json` has `attribution.commit` set (#2078). The Claude Code Bash tool may suggest one in its default commit-message template — ignore it. `Co-Authored-By` is semantic authorship attribution under git/GitHub convention; the tool is the facilitator, not a co-author.
- Keep files under 500 lines
- Validate input at system boundaries

## Agent Comms (SendMessage-First Coordination)

Named agents coordinate via `SendMessage`, not polling or shared state.

```
Lead (you) ←→ architect ←→ developer ←→ tester ←→ reviewer
              (named agents message each other directly)
```

### Spawning a Coordinated Team

```javascript
// ALL agents in ONE message, each knows WHO to message next
Agent({ prompt: "Research the codebase. SendMessage findings to 'architect'.",
  subagent_type: "researcher", name: "researcher", run_in_background: true })
Agent({ prompt: "Wait for 'researcher'. Design solution. SendMessage to 'coder'.",
  subagent_type: "system-architect", name: "architect", run_in_background: true })
Agent({ prompt: "Wait for 'architect'. Implement it. SendMessage to 'tester'.",
  subagent_type: "coder", name: "coder", run_in_background: true })
Agent({ prompt: "Wait for 'coder'. Write tests. SendMessage results to 'reviewer'.",
  subagent_type: "tester", name: "tester", run_in_background: true })
Agent({ prompt: "Wait for 'tester'. Review code quality and security.",
  subagent_type: "reviewer", name: "reviewer", run_in_background: true })

// Kick off the pipeline
SendMessage({ to: "researcher", summary: "Start", message: "[task context]" })
```

### Patterns

| Pattern | Flow | Use When |
|---------|------|----------|
| **Pipeline** | A → B → C → D | Sequential dependencies (feature dev) |
| **Fan-out** | Lead → A, B, C → Lead | Independent parallel work (research) |
| **Supervisor** | Lead ↔ workers | Ongoing coordination (complex refactor) |

### Rules

- ALWAYS name agents — `name: "role"` makes them addressable
- ALWAYS include comms instructions in prompts — who to message, what to send
- Spawn ALL agents in ONE message with `run_in_background: true`
- After spawning: STOP, tell user what's running, wait for results
- NEVER poll status — agents message back or complete automatically

## Swarm & Routing

### Config
- **Topology**: hierarchical (V3 mesh mode not enabled; CLI supports `hierarchical`/`mesh`/...)
- **Max Agents**: 15
- **Memory**: hybrid
- **HNSW**: Enabled
- **Neural**: Enabled

```bash
npx @claude-flow/cli@latest swarm init --topology hierarchical --max-agents 15 --strategy specialized
```

### Agent Routing

| Task | Agents | Topology |
|------|--------|----------|
| Bug Fix | researcher, coder, tester | hierarchical |
| Feature | architect, coder, tester, reviewer | hierarchical |
| Refactor | architect, coder, reviewer | hierarchical |
| Performance | perf-engineer, coder | hierarchical |
| Security | security-architect, auditor | hierarchical |

### When to Swarm
- **YES**: 3+ files, new features, cross-module refactoring, API changes, security, performance
- **NO**: single file edits, 1-2 line fixes, docs updates, config changes, questions

### 3-Tier Model Routing

| Tier | Handler | Use Cases |
|------|---------|-----------|
| 1 | Agent Booster (WASM) | Simple transforms — skip LLM, use Edit directly |
| 2 | Haiku | Simple tasks, low complexity |
| 3 | Sonnet/Opus | Architecture, security, complex reasoning |

## Memory & Learning

### Before Any Task
```bash
npx @claude-flow/cli@latest memory search --query "[task keywords]" --namespace patterns
npx @claude-flow/cli@latest hooks route --task "[task description]"
```

### After Success
```bash
npx @claude-flow/cli@latest memory store --namespace patterns --key "[name]" --value "[what worked]"
npx @claude-flow/cli@latest hooks post-task --task-id "[id]" --success true --store-results true
```

### MCP Tools (use `ToolSearch("keyword")` to discover)

| Category | Key Tools |
|----------|-----------|
| **Memory** | `memory_store`, `memory_search`, `memory_search_unified` |
| **Bridge** | `memory_import_claude`, `memory_bridge_status` |
| **Swarm** | `swarm_init`, `swarm_status`, `swarm_health` |
| **Agents** | `agent_spawn`, `agent_list`, `agent_status` |
| **Hooks** | `hooks_route`, `hooks_post-task`, `hooks_worker-dispatch` |
| **Security** | `aidefence_scan`, `aidefence_is_safe`, `aidefence_has_pii` |
| **Hive-Mind** | `hive-mind_init`, `hive-mind_consensus`, `hive-mind_spawn` |

### Background Workers

| Worker | When |
|--------|------|
| `audit` | After security changes |
| `optimize` | After performance work |
| `testgaps` | After adding features |
| `map` | Every 5+ file changes |
| `document` | After API changes |

```bash
npx @claude-flow/cli@latest hooks worker dispatch --trigger audit
```

## Agents

**Core**: `coder`, `reviewer`, `tester`, `planner`, `researcher`
**Architecture**: `system-architect`, `backend-dev`, `mobile-dev`
**Security**: `security-architect`, `security-auditor`
**Performance**: `performance-engineer`, `perf-analyzer`
**Coordination**: `hierarchical-coordinator`, `mesh-coordinator`, `adaptive-coordinator`
**GitHub**: `pr-manager`, `code-review-swarm`, `issue-tracker`, `release-manager`

Any string works as a custom agent type.

## Build & Test

- ALWAYS run tests after code changes
- ALWAYS verify build succeeds before committing

```bash
npm run build && npm test
```

## CLI Quick Reference

```bash
npx @claude-flow/cli@latest init --wizard           # Setup
npx @claude-flow/cli@latest swarm init --v3-mode     # Start swarm
npx @claude-flow/cli@latest memory search --query "" # Vector search
npx @claude-flow/cli@latest hooks route --task ""    # Route to agent
npx @claude-flow/cli@latest doctor --fix             # Diagnostics
npx @claude-flow/cli@latest security scan            # Security scan
npx @claude-flow/cli@latest performance benchmark    # Benchmarks
```

26 commands, 140+ subcommands. Use `--help` on any command for details.

## Setup

```bash
claude mcp add claude-flow -- npx -y ruflo@latest mcp start
npx ruflo@latest doctor --fix
```

> The background `daemon` is optional. It runs interval workers that each spawn
> a headless `claude` session, so it consumes tokens continuously. Start it only
> if you want those sweeps: `npx ruflo@latest daemon start` (self-stops after 12h
> by default; `--ttl 0` to disable, `daemon status --all` to audit running daemons).

**Agent tool** handles execution (agents, files, code, git). **MCP tools** handle coordination (swarm, memory, hooks). **CLI** is the same via Bash.

---

## Airbyte-specific (project knowledge for this monorepo)

This is the open-source Airbyte monorepo. Above ruflo conventions apply; below is what makes this repo unique.

### Layout
- `airbyte-cdk/` — connector SDKs (Kotlin Bulk CDK + legacy Java CDK; `airbyte-cdk/python/` is a stub pointing at airbytehq/airbyte-python-cdk).
- `airbyte-integrations/connectors/<name>/` — ~600 connectors (sources + destinations).
- `airbyte-integrations/bases/` — Docker base images, dbt normalization.
- `airbyte-ci/connectors/ci_credentials/` — `ci_credentials` CLI for GSM secrets.
- `docusaurus/` — docs.airbyte.com (Docusaurus 3, pnpm 9, Node ≥ 20).
- `poe-tasks/` — shared Poe-the-Poet task files every connector inherits.

### Connector anatomy
Every connector has `metadata.yaml` (truth source: type, definitionId, `dockerImageTag`, support level, base image, test secrets) + `README.md` + `icon.svg` + `acceptance-test-config.yml`. `supportLevel: archived` makes `settings.gradle` skip it.

Three flavors (each inherits a different `poe-tasks/*.toml`):
- **Python** — `pyproject.toml` + `poetry.lock` + `unit_tests/` + `integration_tests/`. Pinned via `poe use-cdk-latest|version|branch|local`.
- **Java/Kotlin** — `build.gradle` (`airbyte-java-connector` plugin: `cdkVersionRequired`, `features`, `useLocalCdk`) + `src/main/{kotlin,java}` + `src/test` + `src/test-integration` + optional `src/testFixtures`.
- **Manifest-only** (`language:manifest-only`, `cdk:low-code`) — only `manifest.yaml`; base image `source-declarative-manifest`. Integration tests via `airbyte-cdk connector test <path>`.

Worked examples: `airbyte-integrations/connectors/source-pokeapi/` (manifest-only) and `destination-bigquery/` (Java/Kotlin).

### Three CDKs, three release models
- **Legacy Java CDK** — single version (`airbyte-cdk/java/airbyte-cdk/core/src/main/resources/version.properties`), JDK 21, Kotlin 2.0. Build: `./gradlew :airbyte-cdk:java:airbyte-cdk:build`. Publish: `/publish-java-cdk` slash command on the PR.
- **Bulk CDK (Kotlin + Micronaut DI, incubating)** — three independently versioned packages: `core/{base,extract,load}/version.properties`. No `useLocalCdk`; tests live inside the CDK via Micronaut-injected fakes. Publishes automatically on push to master via `.github/workflows/publish-bulk-cdk.yml`.
- **Python CDK** — source lives at https://github.com/airbytehq/airbyte-python-cdk. `airbyte-cdk[dev]` CLI installed via `uv tool` by shared Poe tasks.

### Common commands
- `./gradlew :airbyte-integrations:connectors:<name>:<task>` — one Gradle task on one connector (e.g. `test`, `build`, `integrationTestJava`).
- `poe connector <name> <task>` / `poe source <short> <task>` / `poe destination <short> <task>` — root-level dispatch.
- `poe get-modified-connectors [java-only|no-java]` — list touched connectors.
- `poe docs-build` / `poe docs-update-latest-evergreen` — Docusaurus site.
- Inside a Python connector: `poe install`, `poe test-fast`, `poe test-unit-tests`, `poe test-integration-tests`, `poe check-ruff`, `poe check-mypy`, `poe fix-ruff`, `poe fetch-secrets`.
- Inside a Java connector: `poe gradle build`, `poe test-all` (= `gradle check`), `poe test-unit-tests` (= `gradle test`), `poe test-integration-tests` (= `gradle integrationTestJava` if `src/test-integration/` exists).

### Conventions
- Pre-commit (root) runs ruff, prettier (JSON/YAML), `addlicense` (Apache 2.0 from `LICENSE_SHORT`), and Spotless for `.java/.kt/.gradle`.
- Gradle root sets `FAIL_ON_PROJECT_REPOS` — all deps must resolve from repos in `settings.gradle` (Maven Central, `airbyte-public-jars`, plus whitelist repos for elastic / redshift / rockset / awaitility / confluent / jitpack).
- Spotless + SpotBugs run on every Gradle subproject; Kotlin warnings are errors in CI.
- Test secrets live in GSM alias `airbyte-connector-testing-secret-store` and are declared in `metadata.yaml > connectorTestSuitesOptions[*].testSecrets`. Pull locally with `ci_credentials write-to-storage` or `airbyte-ops secrets fetch`.
- Connector docs are versioned. Evergreen source lives in `docs/platform/connector-development/` and mirrors to `docusaurus/platform_versioned_docs/version-<latest>/` via `poe docs-update-latest-evergreen`.

### External pointers
- Live Python CDK: https://github.com/airbytehq/airbyte-python-cdk
- Agent SDK: https://github.com/airbytehq/airbyte-agent-sdk (`uv pip install airbyte-agent-sdk`)
- Published jars: https://airbyte.mycloudrepo.io/public/repositories/airbyte-public-jars/
- PRs must come from a personal fork (org forks can't enable "Allow edits from maintainers").
