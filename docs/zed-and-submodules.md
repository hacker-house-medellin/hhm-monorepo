# Zed packages and Git submodules

`hhm-monorepo` supports mixed checkouts without allowing two package managers to own the same repository.

## Ownership rule

- `.zpkg.toml` is authoritative for package dependencies and installs them under `.vendor/.zed`.
- `.gitmodules` tracks the 14 deployment and integration repositories under `apps/deployments`; none may also appear in `[dependencies]`.
- Equivalent GitHub HTTPS, SSH, and `git://` URLs are normalized before comparison.
- `.zed-submodules.tsv` classifies every gitlink as a workspace or an explicit reference. CLI and infrastructure are deployment workspaces, while the alternate Leptos and Dioxus servers are experiment references.
- Each gitlink records an exact commit. The `branch = main` hint supports maintenance commands but does not make a checkout float at runtime.

## Commands

```bash
bash scripts/validate-zed-submodules.sh
bash scripts/zed-install-with-submodules.sh
```

The installer runs the ownership guard, delegates to `zed install --git-submodules`, and validates again. Generated `.vendor/.zed` state stays uncommitted. The generated `.zpkg.lock` is committed so even an intentionally empty published-package graph has a reproducible resolver result.

For migration from legacy submodules, run `zed overtake --git-submodules` only in a clean worktree, review `.zpkg.toml` and `.zpkg.lock`, and re-run the validator before committing.
