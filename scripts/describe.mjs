import { readFileSync } from 'node:fs';

const args = process.argv.slice(2);
const option = args[0];
if (args.length > 1 || (option !== undefined && option !== '--json' && option !== '--help')) {
  console.error('Usage: node scripts/describe.mjs [--json|--help]');
  process.exitCode = 2;
} else if (option === '--help') {
  console.log('Usage: node scripts/describe.mjs [--json|--help]');
} else {
  const catalog = JSON.parse(readFileSync(new URL('../catalog.json', import.meta.url), 'utf8'));
  const { org, brand, apps, packages } = catalog;
  if (typeof org !== 'string' || !org || typeof brand !== 'string' || !brand
    || !Array.isArray(apps) || !apps.every((item) => typeof item === 'string')
    || !Array.isArray(packages) || !packages.every((item) => typeof item === 'string')) {
    throw new TypeError('catalog requires org, brand, and string arrays for apps/packages');
  }
  if (option === '--json') {
    console.log(JSON.stringify({ org, brand, apps, packages }));
  } else {
    console.log(`${brand} (${org})`);
    console.log(`apps=${apps.join(',')}`);
    console.log(`packages=${packages.join(',')}`);
  }
}
