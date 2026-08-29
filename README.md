# hhm-monorepo

High-context development surface for **Hacker House Medellín**. Split repositories remain independently releasable; this monorepo provides a small, buildable control plane for local integration, contract validation, and repository-family orchestration.

## Package composition

The root is a Zed package for monorepo-native tooling. Published package dependencies belong in `.zpkg.toml` and its generated lockfile; deployment source is pinned independently as exact Git submodule commits under `apps/deployments`.

The deployment set includes the complete canonical repository family—clients, interfaces, sync, CLI, infra, Flutter, Rust desktop, Rust API, Rust web, core library, and E2E—plus the Leptos, Dioxus, and MCP integration repositories. A repository may be represented by Zed or by a gitlink, never both. See `docs/zed-and-submodules.md`.

## Layout

- `apps/control-plane` — Rust binary that validates and prints the service catalog
- `packages/catalog` — typed service metadata shared by tooling
- `apps/api`, `apps/web`, `apps/ops-console` — composition boundaries and integration notes
- `apps/deployments` — 14 exact, reviewable Git links to deployable and integration repositories
- `catalog.json` — machine-readable repository/service inventory
- `docs/architecture.md` — split-repo/monorepo ownership model
- `scripts/validate-zed-submodules.sh` — rejects unclassified or dual-owned dependencies
- `scripts/zed-install-with-submodules.sh` — guarded `zed install --git-submodules`

```bash
./scripts/test.sh
./scripts/validate-zed-submodules.sh
```
