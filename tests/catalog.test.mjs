import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { describeApi } from '../apps/api/src/index.mjs';
import { routes, product } from '../packages/contracts/src/index.mjs';
const catalog = JSON.parse(readFileSync('catalog.json', 'utf8'));
test('catalog links split repositories', () => { assert.equal(catalog.org, "hacker-house-medellin"); assert.equal(catalog.repos.marketing, "hacker-house-medellin/hacker-house-medellin.github.io"); assert.ok(catalog.apps.includes('api')); assert.ok(catalog.packages.includes('contracts')); });
test('api descriptor and contracts agree', () => { assert.equal(product, "hacker-house-medellin"); const api = describeApi(); assert.ok(api.routes.every((route) => routes.includes(route))); });

test('Atto source bindings are discoverable without claiming runnable compiler parity', () => {
  const entry = catalog.language_support?.atto;
  assert.equal(catalog.repos.interfaces, "hacker-house-medellin/hhm-interfaces");
  assert.equal(entry.clients_repo, catalog.repos.clients);
  assert.equal(entry.interfaces_repo, catalog.repos.interfaces);
  assert.equal(entry.client_source, 'clients/atto/src/hhm_client.atto');
  assert.deepEqual(entry.interface_sources, [
    'bindings/atto/src/visitor_access.atto',
    'bindings/atto/src/reservation_status.atto',
  ]);
  assert.equal(entry.phase, 'draft-source-contract');
  assert.equal(entry.runtime_verified, false);
  assert.match(entry.validation, /guest-compiler-unverified/);
});
test('the service catalog descriptor uses brand and reports Atto capability honestly', async () => {
  const { execFileSync } = await import('node:child_process');
  const output = execFileSync(process.execPath, ['scripts/describe.mjs'], { encoding: 'utf8' });
  assert.match(output, /Hacker House Medellín \(hacker-house-medellin\)/);
  assert.match(output, /atto=draft-source-contract runtime_verified=false/);
  assert.doesNotMatch(output, /^undefined /m);
});
