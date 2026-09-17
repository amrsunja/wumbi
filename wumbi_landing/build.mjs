// Builds ./dist from "Wumbi Landing.dc.html".
//
// The page is a Claude Design canvas rendered client-side by support.js (dc-runtime),
// so everything a crawler needs has to be produced here, at build time:
//   1. one static HTML file per locale — / (en, x-default) and /<lang>/ — with its own
//      <html lang|dir>, title, description, canonical and reciprocal hreflang set
//   2. prerendered markup injected ahead of <x-dc> (see prerender.mjs) so the page has
//      real content with JavaScript off; it is removed the moment React mounts
//   3. JSON-LD: SoftwareApplication + Organization + WebSite + WebPage + FAQPage
//   4. sitemap.xml, robots.txt, site.webmanifest, 404.html, .htaccess
//   5. assets: mascots → WebP at display size, fonts and GSAP self-hosted, React vendored
//
// Paths in dist are root-absolute (/assets/…) so a page at any depth resolves them.
import { mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync, existsSync, statSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { execSync } from 'node:child_process';
import { SITE, APP, LOCALES, OG_LOCALE, langPath, langUrl, TEMPLATE_PAGE, LEGAL } from './seo.config.mjs';
import { templatePage } from './template-page.mjs';
import { STATIC_PAGES } from './site-pages.mjs';

const SRC = 'Wumbi Landing.dc.html';
const OUT = 'dist';
const PRERENDER_DIR = join('seo', 'prerendered');
const BUILD_DATE = new Date().toISOString().slice(0, 10);

const REACT_URL = 'https://unpkg.com/react@18.3.1/umd/react.production.min.js';
const REACT_DOM_URL = 'https://unpkg.com/react-dom@18.3.1/umd/react-dom.production.min.js';
const GSAP_URL = 'https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js';
const SCROLLTRIGGER_URL = 'https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/ScrollTrigger.min.js';

// ---------------------------------------------------------------- helpers
// Overwrite-in-place copy (no unlink) so it also works on mounts that forbid deletes.
const copyFile = (from, to) => { mkdirSync(dirname(to), { recursive: true }); writeFileSync(to, readFileSync(from)); };
const write = (rel, body) => { const p = join(OUT, rel); mkdirSync(dirname(p), { recursive: true }); writeFileSync(p, body); };
const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const kb = (p) => (statSync(p).size / 1024).toFixed(0) + ' KB';

// i18n.js is a plain `window.WUMBI_I18N = {…}` assignment plus a merge IIFE — run it
// against a fake window so page copy has exactly one source of truth.
function loadI18n() {
  const win = {};
  new Function('window', readFileSync('i18n.js', 'utf8'))(win);
  if (!win.WUMBI_I18N) throw new Error('build: i18n.js did not set window.WUMBI_I18N');
  return win.WUMBI_I18N;
}

const I18N = loadI18n();
const LANGS = Object.keys(I18N.meta);
for (const l of LANGS) if (!LOCALES[l]) throw new Error(`build: seo.config.mjs has no entry for locale "${l}"`);
const T = (lang, key) => I18N[lang]?.[key] ?? I18N.en[key] ?? '';

// ---------------------------------------------------------------- clean
try { rmSync(OUT, { recursive: true, force: true }); } catch { /* keep going: files are overwritten below */ }
mkdirSync(join(OUT, 'vendor'), { recursive: true });

let html = readFileSync(SRC, 'utf8');

// ---------------------------------------------------------------- assets: images
// Derived images (WebP mascots + icon PNGs) live in assets/derived/ and are COMMITTED.
// The deploy host runs Node 18 and sharp needs >= 20.9, so the production build must not
// touch a native module at all. sharp is imported lazily and only when something in
// assets/derived/ is missing or stale — i.e. locally, right after a source image changes.
const referenced = new Set([...html.matchAll(/assets\/[A-Za-z0-9_/-]+\.(?:png|svg|jpe?g)/g)].map((m) => m[0]));
const DERIVED = join('assets', 'derived');
const MANIFEST = join(DERIVED, 'manifest.json');
const LOGO = 'assets/app_logo.png';
const MASCOTS = {
  'assets/wumbi_hello.png': { width: 600, eager: true },      // hero, display max 300px → LCP
  'assets/wumbi_take_money.png': { width: 600 },              // waitlist card, display max 300px
  'assets/wumbi_look.png': { width: 260 },                    // peeking, display height 64px
};
const ICON_PNGS = [['favicon-32.png', 32], ['favicon-192.png', 192], ['apple-touch-icon.png', 180], ['icon-512.png', 512]];

const readManifest = () => { try { return JSON.parse(readFileSync(MANIFEST, 'utf8')); } catch { return null; } };
let manifest = readManifest();
const fresh = manifest
  && Object.keys(MASCOTS).every((src) => manifest.images[src] && existsSync(join(DERIVED, manifest.images[src].file)))
  && manifest.images[LOGO] && existsSync(join(DERIVED, manifest.images[LOGO].file))
  && ICON_PNGS.every(([n]) => existsSync(join(DERIVED, n)));

if (!fresh) {
  let sharp;
  try { ({ default: sharp } = await import('sharp')); } catch {
    throw new Error(
      'build: assets/derived/ is incomplete and sharp is not installed.\n' +
      '  Locally:  npm i -D sharp && npm run build && git add assets/derived\n' +
      '  The generated files are committed so the deploy host never needs sharp.',
    );
  }
  console.log('  regenerating assets/derived/ with sharp…');
  mkdirSync(DERIVED, { recursive: true });
  const images = {};
  for (const [src, opt] of Object.entries(MASCOTS)) {
    const file = src.replace(/^assets\//, '').replace(/\.png$/, '.webp');
    const buf = await sharp(src).resize({ width: opt.width, withoutEnlargement: true }).webp({ quality: 82, effort: 6 }).toBuffer();
    const meta = await sharp(buf).metadata();
    writeFileSync(join(DERIVED, file), buf);
    images[src] = { file, w: meta.width, h: meta.height, eager: !!opt.eager };
  }
  for (const [name, size] of ICON_PNGS) {
    writeFileSync(join(DERIVED, name), await sharp(LOGO).resize(size, size).png({ compressionLevel: 9 }).toBuffer());
  }
  writeFileSync(join(DERIVED, 'app_logo.webp'), await sharp(LOGO).resize(96, 96).webp({ quality: 88 }).toBuffer());
  images[LOGO] = { file: 'app_logo.webp', w: 96, h: 96 };
  manifest = { generatedWith: 'sharp', images };
  writeFileSync(MANIFEST, JSON.stringify(manifest, null, 2) + '\n');
}

// src → { out, w, h } for the <img> rewrite below.
const imgMeta = {};
for (const [src, m] of Object.entries(manifest.images)) {
  if (src !== LOGO && !referenced.has(src)) continue;
  copyFile(join(DERIVED, m.file), join(OUT, 'assets', m.file));
  imgMeta[src] = { out: `/assets/${m.file}`, w: m.w, h: m.h, eager: !!m.eager };
}
for (const [name] of ICON_PNGS) copyFile(join(DERIVED, name), join(OUT, 'assets', name));
copyFile(LOGO, join(OUT, LOGO)); // untouched original: OG fallback + any external reference

// SVGs: copy every referenced literal, plus the whole icon set — feature icons are
// assembled at runtime (`assets/icons/${name}.svg`) so they never appear as literals.
for (const src of referenced) if (src.endsWith('.svg')) copyFile(src, join(OUT, src));
for (const f of readdirSync(join('assets', 'icons'))) {
  if (f.endsWith('.svg')) copyFile(join('assets', 'icons', f), join(OUT, 'assets', 'icons', f));
}

// Optional per-locale OG images produced by prerender.mjs; app_logo.png is the fallback.
const ogFor = (lang) => {
  const p = join('assets', 'og', `og-${lang}.png`);
  if (existsSync(p)) { copyFile(p, join(OUT, p)); return { url: '/' + p.replace(/\\/g, '/'), w: SITE.ogWidth, h: SITE.ogHeight, type: 'image/png', card: 'summary_large_image' }; }
  return { url: '/assets/icon-512.png', w: 512, h: 512, type: 'image/png', card: 'summary' };
};

// ---------------------------------------------------------------- assets: fonts
// Self-hosted so the render-blocking Google Fonts round-trip disappears (and no
// third-party request from the visitor's browser — the whole point of a local-first app).
const FONT_FILES = [
  ['@fontsource-variable/inter/files/inter-latin-wght-normal.woff2', 'inter-latin.woff2'],
  ['@fontsource-variable/inter/files/inter-latin-ext-wght-normal.woff2', 'inter-latin-ext.woff2'],
  ['@fontsource-variable/inter/files/inter-cyrillic-wght-normal.woff2', 'inter-cyrillic.woff2'],
  ['@fontsource-variable/inter/files/inter-cyrillic-ext-wght-normal.woff2', 'inter-cyrillic-ext.woff2'],
  ['@fontsource/montserrat/files/montserrat-latin-300-normal.woff2', 'montserrat-300.woff2'],
  ['@fontsource/montserrat/files/montserrat-latin-700-normal.woff2', 'montserrat-700.woff2'],
  ['@fontsource/montserrat/files/montserrat-cyrillic-300-normal.woff2', 'montserrat-cyr-300.woff2'],
  ['@fontsource/montserrat/files/montserrat-cyrillic-700-normal.woff2', 'montserrat-cyr-700.woff2'],
  ['@fontsource/noto-sans-arabic/files/noto-sans-arabic-arabic-400-normal.woff2', 'noto-arabic-400.woff2'],
  ['@fontsource/noto-sans-arabic/files/noto-sans-arabic-arabic-600-normal.woff2', 'noto-arabic-600.woff2'],
  ['@fontsource/noto-sans-arabic/files/noto-sans-arabic-arabic-700-normal.woff2', 'noto-arabic-700.woff2'],
];
for (const [from, to] of FONT_FILES) copyFile(join('node_modules', from), join(OUT, 'vendor', 'fonts', to));

const LATIN = 'U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD';
const LATIN_EXT = 'U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF';
const CYRILLIC = 'U+0301,U+0400-045F,U+0490-0491,U+04B0-04B1,U+2116';
const CYRILLIC_EXT = 'U+0460-052F,U+1C80-1C8A,U+20B4,U+2DE0-2DFF,U+A640-A69F,U+FE2E-FE2F';
const ARABIC = 'U+0600-06FF,U+0750-077F,U+0870-088E,U+0890-0891,U+0898-08E1,U+08E3-08FF,U+200C-200E,U+2010-2011,U+204F,U+2E41,U+FB50-FDFF,U+FE70-FEFF';
const face = (family, weight, file, range) =>
  `@font-face{font-family:'${family}';font-style:normal;font-display:swap;font-weight:${weight};` +
  `src:url(/vendor/fonts/${file}) format('woff2');unicode-range:${range}}`;
write('vendor/fonts.css', [
  face('Inter', '100 900', 'inter-latin.woff2', LATIN),
  face('Inter', '100 900', 'inter-latin-ext.woff2', LATIN_EXT),
  face('Inter', '100 900', 'inter-cyrillic.woff2', CYRILLIC),
  face('Inter', '100 900', 'inter-cyrillic-ext.woff2', CYRILLIC_EXT),
  face('Montserrat', '300', 'montserrat-300.woff2', LATIN),
  face('Montserrat', '700', 'montserrat-700.woff2', LATIN),
  face('Montserrat', '300', 'montserrat-cyr-300.woff2', CYRILLIC),
  face('Montserrat', '700', 'montserrat-cyr-700.woff2', CYRILLIC),
  face('Noto Sans Arabic', '400', 'noto-arabic-400.woff2', ARABIC),
  face('Noto Sans Arabic', '600', 'noto-arabic-600.woff2', ARABIC),
  face('Noto Sans Arabic', '700', 'noto-arabic-700.woff2', ARABIC),
].join('\n'));

// ---------------------------------------------------------------- assets: scripts
copyFile('node_modules/react/umd/react.production.min.js', join(OUT, 'vendor', 'react.production.min.js'));
copyFile('node_modules/react-dom/umd/react-dom.production.min.js', join(OUT, 'vendor', 'react-dom.production.min.js'));
copyFile('node_modules/gsap/dist/gsap.min.js', join(OUT, 'vendor', 'gsap.min.js'));
copyFile('node_modules/gsap/dist/ScrollTrigger.min.js', join(OUT, 'vendor', 'ScrollTrigger.min.js'));
copyFile('support.js', join(OUT, 'support.js'));
copyFile('i18n.js', join(OUT, 'i18n.js'));

// ---------------------------------------------------------------- template rewrites
// Root-absolute asset paths, WebP mascots with intrinsic size, local fonts and GSAP.
// width/height attributes are presentational hints: on an image whose CSS sets only ONE
// dimension the other attribute wins and the mascot gets squashed. Pin the missing side
// to auto so the attributes only supply the aspect ratio (which is what fixes CLS).
const autoSide = (tag) => {
  const style = /style="([^"]*)"/.exec(tag)?.[1] || '';
  const has = (prop) => new RegExp(`(^|;)\\s*${prop}\\s*:`).test(style);
  const w = has('width'), h = has('height');
  if (w && !h) return 'height:auto';
  if (h && !w) return 'width:auto';
  return '';
};
for (const [src, m] of Object.entries(imgMeta)) {
  html = html.replace(new RegExp(`<img([^>]*?)src="${src}"([^>]*?)>`, 'g'), (tag, a, b) => {
    const auto = autoSide(tag);
    let rest = b;
    if (auto) {
      rest = /style="[^"]*"/.test(b)
        ? b.replace(/style="([^"]*?);?"/, (_, v) => `style="${v};${auto}"`)
        : `${b} style="${auto}"`;
      if (!/style="/.test(b) && /style="/.test(a)) { rest = b; a = a.replace(/style="([^"]*?);?"/, (_, v) => `style="${v};${auto}"`); }
    }
    return `<img${a}src="${m.out}"${rest} width="${m.w}" height="${m.h}"` +
      (m.eager ? ' decoding="async">' : ' loading="lazy" decoding="async">');
  });
}
html = html.replace(/(src|href)="assets\//g, '$1="/assets/');
html = html.replace(/`assets\//g, '`/assets/'); // template literals in the component script
html = html.replace(/url\(assets\//g, 'url(/assets/');
html = html.replace(/"\.\/(support|i18n)\.js"/g, '"/$1.js"');
html = html.replace(/<link rel="preconnect" href="https:\/\/fonts\.googleapis\.com">\s*/, '');
html = html.replace(/<link href="https:\/\/fonts\.googleapis\.com\/[^"]*" rel="stylesheet">\s*/, '<link rel="stylesheet" href="/vendor/fonts.css">\n');
html = html.replace(GSAP_URL, '/vendor/gsap.min.js').replace(SCROLLTRIGGER_URL, '/vendor/ScrollTrigger.min.js');
if (html.includes('fonts.googleapis.com') || html.includes('cdn.jsdelivr.net')) throw new Error('build: a CDN reference survived the rewrite');

// ---------------------------------------------------------------- structured data
const jsonLd = (lang) => {
  const L = LOCALES[lang];
  const og = ogFor(lang);
  const graph = [
    {
      '@type': 'SoftwareApplication',
      '@id': SITE.url + '/#app',
      name: SITE.name,
      applicationCategory: APP.category,
      applicationSubCategory: APP.subCategory,
      operatingSystem: APP.platforms.join(', '),
      description: L.description,
      inLanguage: LANGS,
      url: langUrl(lang),
      image: SITE.url + og.url,
      featureList: APP.features,
      softwareVersion: '1.0',
      datePublished: '2026-01-01',
      offers: { '@type': 'Offer', price: APP.price, priceCurrency: APP.currency, availability: 'https://schema.org/PreOrder' },
      publisher: { '@id': SITE.url + '/#org' },
    },
    {
      '@type': 'Organization',
      '@id': SITE.url + '/#org',
      name: SITE.name,
      url: SITE.url + '/',
      email: SITE.email,
      logo: { '@type': 'ImageObject', url: SITE.url + '/assets/icon-512.png', width: 512, height: 512 },
    },
    {
      '@type': 'WebSite',
      '@id': SITE.url + '/#website',
      name: SITE.name,
      url: SITE.url + '/',
      inLanguage: lang,
      publisher: { '@id': SITE.url + '/#org' },
    },
    {
      '@type': 'WebPage',
      '@id': langUrl(lang) + '#webpage',
      url: langUrl(lang),
      name: L.title,
      description: L.description,
      inLanguage: lang,
      isPartOf: { '@id': SITE.url + '/#website' },
      about: { '@id': SITE.url + '/#app' },
      primaryImageOfPage: { '@type': 'ImageObject', url: SITE.url + og.url },
    },
    {
      '@type': 'FAQPage',
      '@id': langUrl(lang) + '#faq',
      inLanguage: lang,
      mainEntity: Array.from({ length: 10 }, (_, i) => ({
        '@type': 'Question',
        name: T(lang, `q${i + 1}`),
        acceptedAnswer: { '@type': 'Answer', text: T(lang, `a${i + 1}`) },
      })).filter((q) => q.name && q.acceptedAnswer.text),
    },
  ];
  return JSON.stringify({ '@context': 'https://schema.org', '@graph': graph })
    .replace(/</g, '\\u003c'); // never let page copy close the <script> tag
};

// ---------------------------------------------------------------- head
const head = (lang) => {
  const L = LOCALES[lang];
  const og = ogFor(lang);
  const hero = imgMeta['assets/wumbi_hello.png'];
  const v = SITE.verification;
  return [
    `<title>${esc(L.title)}</title>`,
    `<meta name="description" content="${esc(L.description)}">`,
    L.keywords?.length ? `<meta name="keywords" content="${esc(L.keywords.join(', '))}">` : '',
    `<meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1">`,
    `<meta name="theme-color" content="${SITE.themeColor}">`,
    `<meta name="apple-mobile-web-app-title" content="${SITE.name}">`,
    `<meta name="format-detection" content="telephone=no">`,
    v.google ? `<meta name="google-site-verification" content="${esc(v.google)}">` : '',
    v.bing ? `<meta name="msvalidate.01" content="${esc(v.bing)}">` : '',
    v.yandex ? `<meta name="yandex-verification" content="${esc(v.yandex)}">` : '',
    '',
    `<link rel="canonical" href="${langUrl(lang)}">`,
    ...LANGS.map((l) => `<link rel="alternate" hreflang="${l}" href="${langUrl(l)}">`),
    `<link rel="alternate" hreflang="x-default" href="${langUrl(SITE.defaultLang)}">`,
    '',
    `<link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon-32.png">`,
    `<link rel="icon" type="image/png" sizes="192x192" href="/assets/favicon-192.png">`,
    `<link rel="apple-touch-icon" href="/assets/apple-touch-icon.png">`,
    `<link rel="manifest" href="/site.webmanifest">`,
    '',
    `<link rel="preload" as="font" type="font/woff2" href="/vendor/fonts/inter-latin.woff2" crossorigin>`,
    I18N.meta[lang].dir === 'rtl' ? `<link rel="preload" as="font" type="font/woff2" href="/vendor/fonts/noto-arabic-400.woff2" crossorigin>` : '',
    lang === 'ru' ? `<link rel="preload" as="font" type="font/woff2" href="/vendor/fonts/inter-cyrillic.woff2" crossorigin>` : '',
    hero ? `<link rel="preload" as="image" href="${hero.out}" fetchpriority="high">` : '',
    `<link rel="stylesheet" href="/vendor/fonts.css">`,
    '',
    `<meta property="og:type" content="website">`,
    `<meta property="og:site_name" content="${SITE.name}">`,
    `<meta property="og:title" content="${esc(L.ogTitle || L.title)}">`,
    `<meta property="og:description" content="${esc(L.description)}">`,
    `<meta property="og:url" content="${langUrl(lang)}">`,
    `<meta property="og:locale" content="${OG_LOCALE[lang]}">`,
    ...LANGS.filter((l) => l !== lang).map((l) => `<meta property="og:locale:alternate" content="${OG_LOCALE[l]}">`),
    `<meta property="og:image" content="${SITE.url}${og.url}">`,
    `<meta property="og:image:width" content="${og.w}">`,
    `<meta property="og:image:height" content="${og.h}">`,
    `<meta property="og:image:type" content="${og.type}">`,
    `<meta property="og:image:alt" content="${esc(L.ogAlt)}">`,
    '',
    `<meta name="twitter:card" content="${og.card}">`,
    SITE.twitter ? `<meta name="twitter:site" content="${SITE.twitter}">` : '',
    `<meta name="twitter:title" content="${esc(L.ogTitle || L.title)}">`,
    `<meta name="twitter:description" content="${esc(L.description)}">`,
    `<meta name="twitter:image" content="${SITE.url}${og.url}">`,
    `<meta name="twitter:image:alt" content="${esc(L.ogAlt)}">`,
    '',
    `<script type="application/ld+json">${jsonLd(lang)}</script>`,
    '',
    `<script>window.WUMBI_LANG=${JSON.stringify(lang)};window.WUMBI_LANG_URLS=${JSON.stringify(Object.fromEntries(LANGS.map((l) => [l, langPath(l)])))};window.__resources=${JSON.stringify({
      [REACT_URL]: '/vendor/react.production.min.js',
      [REACT_DOM_URL]: '/vendor/react-dom.production.min.js',
    })};</script>`,
    `<script src="/i18n.js"></script>`,
    `<script src="/support.js"></script>`,
  ].filter((l) => l !== '').join('\n');
};

// Swap the prerendered snapshot out the instant React puts something in #dc-root.
// With JS off (or broken) the snapshot simply stays — that is the crawler's copy.
// The snapshot must be gone BEFORE componentDidMount runs: the component looks its
// nodes up with getElementById (#tag-graph, #hero-total, #waitlist…) and would otherwise
// grab the snapshot's copy — the one about to be deleted. So the observer fires on
// #dc-root merely EXISTING (support.js inserts it immediately before render, and a
// MutationObserver callback is a microtask, so it lands before React's commit task).
// Removing it also changes the document height, which invalidates every ScrollTrigger
// position GSAP measured — refresh, or nothing below the fold reveals.
const SWAP = `<script>(function(){` +
  `function refresh(){if(window.ScrollTrigger)window.ScrollTrigger.refresh();}` +
  `function d(){var p=document.getElementById('dc-prerender');if(!p)return true;` +
  `if(!document.getElementById('dc-root'))return false;p.parentNode.removeChild(p);` +
  `requestAnimationFrame(refresh);setTimeout(refresh,300);setTimeout(refresh,1200);` +
  `addEventListener('load',function(){setTimeout(refresh,100)});return true}` +
  `if(d())return;var o=new MutationObserver(function(){if(d())o.disconnect()});` +
  `o.observe(document.body,{childList:true,subtree:true});setTimeout(function(){o.disconnect()},2e4)})();</script>`;

// ---------------------------------------------------------------- pages
const MARKER = '<script src="/i18n.js"></script>\n<script src="/support.js"></script>';
if (!html.includes(MARKER)) throw new Error(`build: script marker not found in ${SRC}`);

let prerendered = 0;
for (const lang of LANGS) {
  const { dir } = I18N.meta[lang];
  let page = html
    .replace('<html>', `<html lang="${lang}" dir="${dir}">`)
    .replace(MARKER, head(lang));

  const snap = join(PRERENDER_DIR, `${lang}.html`);
  if (existsSync(snap)) {
    page = page
      .replace('</head>', '<style>x-dc{display:none!important}</style>\n</head>')
      .replace('<x-dc>', `<div id="dc-prerender">${readFileSync(snap, 'utf8')}</div>\n${SWAP}\n<x-dc>`);
    prerendered++;
  }
  write(join(langPath(lang).replace(/^\/|\/$/g, ''), 'index.html'), page);
}

// ---------------------------------------------------------------- sitemap / robots / manifest / 404 / htaccess
// Per Google's sitemap docs: <priority> and <changefreq> are ignored outright, and
// <lastmod> is only used "if it's consistently and verifiably accurate" — so it comes
// from seo/prerendered/lastmod.json, which prerender.mjs only bumps when the rendered
// content of that locale actually changed. A build alone never moves the date.
const LASTMOD = (() => {
  try { return JSON.parse(readFileSync(join(PRERENDER_DIR, 'lastmod.json'), 'utf8')); } catch { return {}; }
})();
const lastmodFor = (lang) => LASTMOD[lang]?.date || BUILD_DATE;

// ---------------------------------------------------------------- template landing page
// A static, non-localised page at /free-budget-planner-template/ that gives away our own
// budget spreadsheet. See template-page.mjs for why it is separate from the app pages.
const TEMPLATE_XLSX = 'assets/templates/Wumbi-Budget-Planner-Template.xlsx';
if (!existsSync(TEMPLATE_XLSX)) throw new Error(`build: ${TEMPLATE_XLSX} is missing`);
copyFile(TEMPLATE_XLSX, join(OUT, TEMPLATE_XLSX));
write(TEMPLATE_PAGE.path.replace(/^\/|\/$/g, '') + '/index.html', templatePage());

// ---------------------------------------------------------------- about / privacy / terms / press
// English only by design: one authoritative version of a legal text beats seven
// translations of it. See the header of site-pages.mjs.
for (const [path, render] of STATIC_PAGES) write(path.replace(/^\/|\/$/g, '') + '/index.html', render());
const MISSING_LEGAL = ['operator', 'address', 'governingLaw'].filter((k) => !LEGAL[k]);

write('sitemap.xml', `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
${LANGS.map((lang) => `  <url>
    <loc>${esc(langUrl(lang))}</loc>
    <lastmod>${lastmodFor(lang)}</lastmod>
${LANGS.map((l) => `    <xhtml:link rel="alternate" hreflang="${l}" href="${esc(langUrl(l))}"/>`).join('\n')}
    <xhtml:link rel="alternate" hreflang="x-default" href="${esc(langUrl(SITE.defaultLang))}"/>
  </url>`).join('\n')}
${[TEMPLATE_PAGE.path, ...STATIC_PAGES.map(([sp]) => sp)].map((sp) => `  <url>
    <loc>${esc(SITE.url + sp)}</loc>
    <lastmod>${sp === '/privacy/' || sp === '/terms/' ? LEGAL.effectiveDate : BUILD_DATE}</lastmod>
  </url>`).join('\n')}
</urlset>
`);

write('robots.txt', `# ${SITE.name} — ${SITE.url}
User-agent: *
Allow: /
Disallow: /vendor/

# Answer engines: Wumbi wants to be quotable.
User-agent: GPTBot
Allow: /
User-agent: OAI-SearchBot
Allow: /
User-agent: ChatGPT-User
Allow: /
User-agent: ClaudeBot
Allow: /
User-agent: Claude-Web
Allow: /
User-agent: PerplexityBot
Allow: /
User-agent: Google-Extended
Allow: /
User-agent: Applebot-Extended
Allow: /

Sitemap: ${SITE.url}/sitemap.xml
`);

write('site.webmanifest', JSON.stringify({
  name: SITE.name,
  short_name: SITE.name,
  description: LOCALES.en.description,
  start_url: '/',
  scope: '/',
  display: 'standalone',
  background_color: SITE.bgColor,
  theme_color: SITE.themeColor,
  lang: SITE.defaultLang,
  icons: [
    { src: '/assets/favicon-192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
    { src: '/assets/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' },
  ],
}, null, 2));

write('404.html', `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Page not found — ${SITE.name}</title>
<meta name="robots" content="noindex,follow">
<link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon-32.png">
<link rel="stylesheet" href="/vendor/fonts.css">
<style>html,body{margin:0;height:100%;background:${SITE.bgColor};color:#456285;font:400 16px Inter,system-ui,sans-serif;display:grid;place-items:center;text-align:center}
a{color:#3B82F6;text-decoration:none;font-weight:600}main{padding:32px;display:flex;flex-direction:column;gap:14px;align-items:center}
h1{margin:0;font-size:clamp(32px,6vw,52px);font-weight:300;letter-spacing:-1px}p{margin:0;color:#6F7F92}</style>
</head>
<body><main>
<img src="/assets/favicon-192.png" alt="${SITE.name}" width="72" height="72" style="border-radius:20px">
<h1>404</h1>
<p>That page moved, or never existed.</p>
<a href="/">← Back to ${SITE.name}</a>
</main></body>
</html>
`);

// Apache config for dist/. The body lives in htaccess.src so it can be edited and
// diffed as a real file; build.mjs only copies it and asserts it is still sane.
// Note the repository root has its OWN .htaccess (the document root is the repo
// root on Hostinger, not dist/) — the two are not interchangeable.
const HTACCESS_SRC = 'htaccess.src';
if (!existsSync(HTACCESS_SRC)) throw new Error(`build: ${HTACCESS_SRC} is missing`);
const htaccess = readFileSync(HTACCESS_SRC, 'utf8');
for (const needle of [
  'RewriteEngine On',
  'wumbi_landing/dist',          // the duplicate-path guard
  '%{THE_REQUEST}',              // ...which must be THE_REQUEST-based, or it loops
  'ErrorDocument 404',
]) {
  if (!htaccess.includes(needle)) throw new Error(`build: ${HTACCESS_SRC} lost a required directive: ${needle}`);
}
write('.htaccess', htaccess);

// Deploy stamp. The only reliable way to answer "is what I built actually live?"
// — dist/ is gitignored, so a green `git push` proves nothing about the server.
const stamp = (() => {
  let sha = 'nogit';
  try { sha = execSync('git rev-parse --short HEAD', { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim(); } catch { /* not a checkout */ }
  return `${new Date().toISOString()} ${sha}\n`;
})();
write('build-stamp.txt', stamp);

// ---------------------------------------------------------------- report
if (!existsSync(join(OUT, 'assets', 'app_logo.png'))) throw new Error('build: assets missing');
const pages = LANGS.map((l) => langPath(l)).join(' ');
console.log(`built ${OUT}/  pages: ${pages}`);
console.log(`  static: ${TEMPLATE_PAGE.path} ${STATIC_PAGES.map(([sp]) => sp).join(' ')}`);
if (MISSING_LEGAL.length) console.warn(`  !! seo.config.mjs LEGAL is incomplete (${MISSING_LEGAL.join(', ')}). /privacy/ and /terms/ say so in plain text. Fill them in and have a lawyer read both pages before launch.`);
console.log(`  index.html ${kb(join(OUT, 'index.html'))} · support.js ${kb(join(OUT, 'support.js'))} · i18n.js ${kb(join(OUT, 'i18n.js'))}`);
console.log(`  prerendered ${prerendered}/${LANGS.length} locales${prerendered === 0 ? '  ← run `npm run prerender` (needs Playwright + Chromium)' : ''}`);
console.log(`  sitemap.xml · robots.txt · site.webmanifest · 404.html · .htaccess`);
console.log(`  build-stamp.txt ${stamp.trim()}`);
