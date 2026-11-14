import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const command = fileURLToPath(new URL('../scripts/describe.mjs', import.meta.url));
const run = (...args) => spawnSync(process.execPath, [command, ...args], { encoding: 'utf8' });

test('catalog summary reports the actual brand, not a missing title', () => {
  const output = run();
  assert.equal(output.status, 0, output.stderr);
  assert.match(output.stdout, /^Hacker House Medellín \(hacker-house-medellin\)\n/);
  assert.match(output.stdout, /apps=api,web,ops-console,control-plane/);
  assert.doesNotMatch(output.stdout, /undefined/);
});

test('--json exports public structured metadata for tooling', () => {
  const output = run('--json');
  assert.equal(output.status, 0, output.stderr);
  const parsed = JSON.parse(output.stdout);
  assert.equal(parsed.org, 'hacker-house-medellin');
  assert.equal(parsed.brand, 'Hacker House Medellín');
  assert.ok(parsed.apps.includes('api'));
  assert.ok(parsed.packages.includes('contracts'));
  assert.deepEqual(Object.keys(parsed), ['org', 'brand', 'apps', 'packages']);
});

test('rejects unknown options and too many arguments', () => {
  for (const args of [['--secret'], ['--json', 'extra']]) {
    const output = run(...args);
    assert.equal(output.status, 2);
    assert.match(output.stderr, /Usage: /);
    assert.equal(output.stdout, '');
  }
});
