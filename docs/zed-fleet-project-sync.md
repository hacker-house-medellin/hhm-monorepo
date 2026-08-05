# Zed fleet and project synchronization

Status date: 2026-08-05

This document is the durable cross-system status record for the canonical `hacker-house-medellin` source fleet. It keeps GitHub repositories, GitHub Project #1, and the Linear project `github.com/hacker-house-medellin` aligned without creating a second package namespace.

## Canonical package graph

| Consumer | Required Zed dependencies |
| --- | --- |
| `hhm-clients` | `hacker-house-medellin/hhm-interfaces` |
| `hhm-libs` | `hacker-house-medellin/hhm-interfaces` |
| `hhm-sync` | `hacker-house-medellin/hhm-interfaces` |
| `hhm-cli` | `hhm-clients`, `hhm-interfaces`, `hhm-libs` |
| API and web servers | `hhm-interfaces`, `hhm-libs`, `hhm-sync`, `shared-auth/shared-auth-clients` |
| `hhm-monorepo` | clients, interfaces, libs, CLI, sync, and shared-auth clients |
| planned `hhm-mcp-server.rs` | clients, interfaces, libs, CLI, sync, and shared-auth clients |
| planned `hhm-e2e` | clients, interfaces, libs, and CLI |

Dependencies materialize under `.vendor/.zed`. Generated dependency trees are not committed or published. `.zpkg.lock` is generated only by a real successful resolver run; it is never fabricated from repository metadata.

## Completed delivery

- `hhm-monorepo#5` completed the canonical short-name dependency graph.
- `hhm-sync#3` added the missing Zed package identity and canonical interfaces dependency.
- API, Mash, Leptos, and Dioxus packages consume interfaces, libs, sync, and shared-auth clients.
- `hhm-cli` consumes clients, interfaces, and libs.
- Long-name repositories are compatibility history only. New package coordinates, issues, pull requests, releases, and submodule adoption use `hhm-*`.

## Test delivery

The planned product-level `hhm-e2e` package owns cross-product Playwright, Puppeteer, Selenium, API, and WebSocket smoke contracts. The broader `hacker-house-medellin-test` certification fleet is tracked separately so specialized privacy, coliving, coworking, application, stay, room, and event scenarios do not become coupled to one product repository.

## Remaining repositories

| Repository | GitHub tracker | Linear tracker |
| --- | --- | --- |
| `hacker-house-medellin/hhm-mcp-server.rs` | `hhm-monorepo#2` | `DEN-2293` |
| `hacker-house-medellin/hhm-e2e` | `hhm-monorepo#8` | `DEN-2294` |

Both repositories are blocked only on organization-level repository creation. Once created, the connected GitHub write path can create branches and files, push commits, open pull requests, inspect checks, and merge.

## Git and Zed ownership rule

Git submodules remain valid exact-source transport, but the same repository must not be represented twice in one composition. Intentional Zed adoption uses `zed overtake --git-submodules`: Git retains the committed gitlink and source checkout, while Zed owns package identity, dependency intent, materialization, and immutable lock provenance. Non-Zed submodules remain solely Git-managed.

Every committed gitlink must be classified in `.zed-submodules.tsv`. CI rejects unclassified gitlinks, long-name duplicate coordinates, committed `.vendor/.zed` or `zed_modules` content, and any repository used simultaneously as a Zed dependency and a submodule.

## Planning authorities

- GitHub organization: `hacker-house-medellin`
- GitHub Project: organization Project #1
- Linear project: `github.com/hacker-house-medellin`
- Parent fleet issue: `DEN-1950`
- Certification-fleet issue: `DEN-2032`
- Repository-creation capability issue: `DEN-319`

GitHub issues and implementation pull requests must link the matching Linear issue and organization Project. Status is updated in both systems when a repository is created, a PR is merged, or a dependency/lock gate changes.