# Zed dependency graph

This repository family uses the short `hhm-*` names as the only canonical package identities.

## Required edges

| Consumer role | Required Zed dependencies |
| --- | --- |
| `hhm-clients` | `hhm-interfaces` |
| `hhm-lib-core` | `hhm-interfaces` |
| API and web/UI servers | `hhm-interfaces`, `hhm-lib-core`, `hhm-sync`; backend-capable services also use the official Shared Auth client and `ores-otel` |
| `hhm-cli` | `hhm-clients`, `hhm-interfaces`, `hhm-lib-core` |
| `hhm-mcp-server.rs` | `hhm-clients`, `hhm-interfaces`, `hhm-lib-core`, `hhm-sync`, the official Shared Auth client |
| `hhm-e2e` | `hhm-clients`, `hhm-interfaces`, `hhm-lib-core`, `hhm-cli` |
| `hhm-monorepo` | exact gitlinks to the complete deployment family until those packages are published |

The table is the intended published-package graph. The root `.zpkg.toml` is the executable Zed contract and must contain only resolvable registry packages; unpublished family repositories remain exact deployment gitlinks rather than misleading package declarations. Repositories that implement a UI or backend use `hhm-sync`; backend services that authenticate users use the official `shared-auth/shared-auth-clients` implementation and fail closed.

## Git submodule interoperability

Zed packages are the dependency mechanism for published libraries. Git submodules pin deployable applications and integration repositories whose source must be composed before their packages are published:

```bash
git submodule update --init --recursive
zed install --git-submodules
```

Do not represent the same repository as both a Zed dependency and a gitlink. Retained gitlinks must be classified in `.zed-submodules.tsv`; use `zed overtake --git-submodules` when deliberately migrating submodules into Zed dependencies. Never commit `.vendor/.zed` or `zed_modules`.

## Naming and consolidation

Do not add full-name package aliases such as `hacker-house-medellin-clients`. The long-name repositories are compatibility history only; all new issues, releases, dependencies, and submodules target the short-name repositories.
