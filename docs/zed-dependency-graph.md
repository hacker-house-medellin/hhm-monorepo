# Zed dependency graph

This repository family uses the short `hhm-*` names as the only canonical package identities.

## Required edges

| Consumer role | Required Zed dependencies |
| --- | --- |
| `hhm-clients` | `hhm-interfaces` |
| `hhm-libs` | `hhm-interfaces` |
| API and web/UI servers | `hhm-interfaces`, `hhm-libs`, `hhm-sync`; backend-capable services also use `shared-auth-clients` |
| `hhm-cli` | `hhm-clients`, `hhm-interfaces`, `hhm-libs` |
| planned `hhm-mcp-server.rs` | `hhm-clients`, `hhm-interfaces`, `hhm-libs`, `hhm-sync`, `shared-auth-clients` |
| planned `hhm-e2e` | `hhm-clients`, `hhm-interfaces`, `hhm-libs`, `hhm-cli` |
| `hhm-monorepo` | the complete shared graph: clients, interfaces, libs, CLI, sync, and shared auth |

The root `.zpkg.toml` is the executable contract for the monorepo row. Repositories that implement a UI or backend must depend on `hhm-sync`; backend services that authenticate users should depend on `shared-auth/shared-auth-clients`.

## Git submodule interoperability

Zed packages are the dependency mechanism. Git submodules remain supported for intentionally embedded source, fixtures, or transition work:

```bash
git submodule update --init --recursive
zed install --git-submodules
```

Do not represent the same repository as both a Zed dependency and a gitlink. Retained gitlinks must be classified in `.zed-submodules.tsv`; use `zed overtake --git-submodules` when deliberately migrating submodules into Zed dependencies. Never commit `.vendor/.zed` or `zed_modules`.

## Naming and consolidation

Do not add full-name package aliases such as `hacker-house-medellin-clients`. The long-name repositories are compatibility history only; all new issues, releases, dependencies, and submodules target the short-name repositories.
