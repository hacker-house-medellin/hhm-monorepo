# Architecture

Hacker House Medellín uses a split-repo plus monorepo model:

- `hhm-clients`: generated and hand-written SDKs.
- `hhm-libs`: shared contracts and validation logic.
- `hhm-infra`: Cloudflare Worker edge routes, bindings, and deployment config.
- `hacker-house-medellin.github.io`: Astro marketing site.
- `hhm-monorepo`: integrated product development surface.

## Milestones

1. Wire monorepo packages to split `libs` contracts.
2. Generate OpenAPI from Worker route metadata.
3. Add e2e tests against Worker preview URLs and SDK clients.
4. Add observability propagation: request IDs, structured JSON logs, trace IDs, and dashboard links.
