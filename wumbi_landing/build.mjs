// Builds ./dist from "Wumbi Landing.dc.html": index.html + support.js + assets + vendored React.
// No bundler: the page is rendered client-side by support.js (dc-runtime); we only
// (1) name it index.html, (2) add SEO/OG head tags, (3) point the runtime at local React
// copies instead of unpkg via window.__resources.
import { mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const SRC = 'Wumbi Landing.dc.html';
const OUT = 'dist';
const SITE = {
  title: 'Wumbi — Track money in seconds',
  description: 'Local-first budgeting. Log income, expenses and transfers in seconds, in 13 currencies, with no account and no bank linking.',
  url: process.env.SITE_URL || 'https://wumbi.app',
  image: 'assets/app_logo.png',
  themeColor: '#3B82F6',
};

const LANGS = ['en', 'fr', 'de', 'nl', 'tr', 'ru', 'ar']; // must match i18n.js meta

const REACT_URL = 'https://unpkg.com/react@18.3.1/umd/react.production.min.js';
const REACT_DOM_URL = 'https://unpkg.com/react-dom@18.3.1/umd/react-dom.production.min.js';

// Overwrite-in-place copy (writeFileSync, no unlink) so it also works on mounts that forbid deletes.
const copyFile = (from, to) => { mkdirSync(join(to, '..'), { recursive: true }); writeFileSync(to, readFileSync(from)); };
const copyDir = (from, to) => {
  for (const e of readdirSync(from, { withFileTypes: true })) {
    if (e.name === '.DS_Store') continue;
    e.isDirectory() ? copyDir(join(from, e.name), join(to, e.name)) : copyFile(join(from, e.name), join(to, e.name));
  }
};

try { rmSync(OUT, { recursive: true, force: true }); } catch { /* keep going: files are overwritten below */ }
mkdirSync(join(OUT, 'vendor'), { recursive: true });

// Vendor React so the live site has no unpkg dependency.
// (paths, not require.resolve: react's "exports" map doesn't expose umd/)
copyFile('node_modules/react/umd/react.production.min.js', join(OUT, 'vendor', 'react.production.min.js'));
copyFile('node_modules/react-dom/umd/react-dom.production.min.js', join(OUT, 'vendor', 'react-dom.production.min.js'));
copyFile('support.js', join(OUT, 'support.js'));
copyFile('i18n.js', join(OUT, 'i18n.js'));
copyDir('assets', join(OUT, 'assets'));

let html = readFileSync(SRC, 'utf8');
const abs = (p) => new URL(p, SITE.url.replace(/\/?$/, '/')).href;
const head = `
<title>${SITE.title}</title>
<meta name="description" content="${SITE.description}">
<meta name="theme-color" content="${SITE.themeColor}">
<link rel="icon" type="image/png" href="assets/app_logo.png">
<link rel="apple-touch-icon" href="assets/app_logo.png">
<link rel="canonical" href="${SITE.url}">
${LANGS.map((l) => `<link rel="alternate" hreflang="${l}" href="${SITE.url}?lang=${l}">`).join('\n')}
<link rel="alternate" hreflang="x-default" href="${SITE.url}">
<meta property="og:type" content="website">
<meta property="og:site_name" content="Wumbi">
<meta property="og:title" content="${SITE.title}">
<meta property="og:description" content="${SITE.description}">
<meta property="og:url" content="${SITE.url}">
<meta property="og:image" content="${abs(SITE.image)}">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="${SITE.title}">
<meta name="twitter:description" content="${SITE.description}">
<meta name="twitter:image" content="${abs(SITE.image)}">
<script>window.__resources=${JSON.stringify({ [REACT_URL]: './vendor/react.production.min.js', [REACT_DOM_URL]: './vendor/react-dom.production.min.js' })};</script>
<script src="./i18n.js"></script>
<script src="./support.js"></script>`;

const marker = '<script src="./i18n.js"></script>\n<script src="./support.js"></script>';
if (!html.includes(marker)) throw new Error(`build: "${marker}" not found in ${SRC}`);
html = html.replace(marker, head.trim());
writeFileSync(join(OUT, 'index.html'), html);

const kb = (p) => (readFileSync(p).length / 1024).toFixed(0) + ' KB';
console.log(`built ${OUT}/index.html (${kb(join(OUT, 'index.html'))}), support.js (${kb(join(OUT, 'support.js'))}), vendor/react*, assets/`);
if (!existsSync(join(OUT, 'assets', 'app_logo.png'))) throw new Error('build: assets missing');
