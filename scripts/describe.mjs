import { readFileSync } from 'node:fs';
const catalog = JSON.parse(readFileSync(new URL('../catalog.json', import.meta.url), 'utf8'));
console.log(`${catalog.brand} (${catalog.org})`);
console.log(`apps=${catalog.apps.join(',')}`);
console.log(`packages=${catalog.packages.join(',')}`);

for (const [language, entry] of Object.entries(catalog.language_support ?? {})) {
  console.log(`${language}=${entry.phase} runtime_verified=${entry.runtime_verified}`);
}
