// Snapshots the client-rendered page to static HTML, one file per locale, plus a
// 1200×630 Open Graph image per locale.
//
//   npm run build        # produces dist/ (no snapshots yet on a clean checkout)
//   npm run prerender    # serves dist/, drives Chromium, writes seo/prerendered/*.html
//                        # and assets/og/og-*.png
//   npm run build        # picks the snapshots up and injects them
//
// Output is COMMITTED to the repo on purpose: the host (Hostinger) only runs
// `npm install && npm run build`, which must never need to download a browser.
// Re-run this whenever the page copy or layout changes.
//
// Requires a local Chromium:  npm i -D playwright && npx playwright install chromium
import { createHash } from 'node:crypto';
import { createServer } from 'node:http';
import { readFileSync, existsSync, mkdirSync, writeFileSync, statSync } from 'node:fs';
import { join, extname, resolve } from 'node:path';
import { SITE, LOCALES, langPath } from './seo.config.mjs';

const OUT = 'dist';
const SNAP_DIR = join('seo', 'prerendered');
const OG_DIR = join('assets', 'og');
const PORT = Number(process.env.PRERENDER_PORT || 4180);

let sharp = null;
try { ({ default: sharp } = await import('sharp')); } catch { /* OG images just stay uncompressed */ }
let chromium;
try { ({ chromium } = await import('playwright')); } catch {
  console.error('prerender: Playwright is not installed.\n  npm i -D playwright && npx playwright install chromium');
  process.exit(1);
}
if (!existsSync(join(OUT, 'index.html'))) { console.error('prerender: run `npm run build` first.'); process.exit(1); }

// ---------------------------------------------------------------- static server
const MIME = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.json': 'application/json', '.webmanifest': 'application/manifest+json',
  '.png': 'image/png', '.webp': 'image/webp', '.svg': 'image/svg+xml', '.woff2': 'font/woff2',
  '.xml': 'application/xml', '.txt': 'text/plain; charset=utf-8',
};
const server = createServer((req, res) => {
  let p = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  if (p.endsWith('/')) p += 'index.html';
  const file = resolve(OUT, '.' + p);
  if (!file.startsWith(resolve(OUT)) || !existsSync(file) || !statSync(file).isFile()) { res.writeHead(404).end('404'); return; }
  res.writeHead(200, { 'Content-Type': MIME[extname(file)] || 'application/octet-stream' });
  res.end(readFileSync(file));
});
await new Promise((r) => server.listen(PORT, r));
const base = `http://127.0.0.1:${PORT}`;

// ---------------------------------------------------------------- browser
const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH || undefined });
const langs = Object.keys(LOCALES);
mkdirSync(SNAP_DIR, { recursive: true });
mkdirSync(OG_DIR, { recursive: true });

// GSAP reveals leave inline opacity/transform behind; a snapshot has to be the settled
// state, otherwise the no-JS copy renders invisible.
// Strip GSAP's leftovers so the snapshot is the settled state — and byte-identical
// between runs. Whether a finished tween leaves `opacity: 1` behind or clears the
// property is a race; either way the element is fully visible, so drop it outright.
// Only elements GSAP actually touched: `translate: none` is its fingerprint, and
// clearing opacity everywhere would flatten the design's own `opacity: .75` spans.
const SETTLE = `(() => {
  const touched = '[data-reveal],[data-hero],[data-phone],[data-bar],[data-reveal-stagger] > *,#hero-phone,#hero-mascot,[style*="translate: none"]';
  document.querySelectorAll(touched).forEach((el) => {
    for (const prop of ['opacity', 'transform', 'translate', 'rotate', 'scale', 'visibility']) el.style.removeProperty(prop);
  });
  document.querySelectorAll('[id^="dc-prerender"]').forEach((el) => el.remove());
  const r = document.getElementById('dc-root');
  return r ? r.innerHTML : '';
})()`;

// <lastmod> must be the date the page's content actually changed, not the date of the
// last build — Google only trusts it "if it's consistently and verifiably accurate".
// The snapshot IS the content, so hash it: same hash → keep the old date.
const LASTMOD_FILE = join(SNAP_DIR, 'lastmod.json');
const prevLastmod = existsSync(LASTMOD_FILE) ? JSON.parse(readFileSync(LASTMOD_FILE, 'utf8')) : {};
const lastmod = {};
const today = new Date().toISOString().slice(0, 10);

for (const lang of langs) {
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.goto(base + langPath(lang), { waitUntil: 'networkidle' });
  await page.waitForFunction('!!document.querySelector("#dc-root")?.firstChild', null, { timeout: 20000 });
  // Walk the page so every ScrollTrigger fires, then come back for a clean top state.
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += 600) { window.scrollTo(0, y); await new Promise((r) => setTimeout(r, 60)); }
    window.scrollTo(0, 0); await new Promise((r) => setTimeout(r, 400));
  });
  // The hero total counts up over ~2.3s; capturing mid-tween would bake a wrong number
  // into the crawler's copy AND make the snapshot non-deterministic (so lastmod would
  // move on every run). Wait until #dc-root stops changing at all.
  await page.waitForFunction(() => {
    const r = document.getElementById('dc-root');
    if (!r) return false;
    const h = r.innerHTML, prev = window.__snapPrev;
    window.__snapPrev = h;
    return prev === h;
  }, null, { timeout: 20000, polling: 500 });
  const snapshot = await page.evaluate(SETTLE);
  if (!snapshot || snapshot.length < 5000) throw new Error(`prerender: ${lang} snapshot looks empty (${snapshot.length} chars)`);
  if (snapshot.includes('{{')) throw new Error(`prerender: ${lang} snapshot still contains {{ }} placeholders`);
  writeFileSync(join(SNAP_DIR, `${lang}.html`), snapshot);
  const hash = createHash('sha1').update(snapshot).digest('hex').slice(0, 16);
  const prev = prevLastmod[lang];
  lastmod[lang] = prev && prev.hash === hash ? prev : { hash, date: today };
  console.log(`  ${lang}: ${(snapshot.length / 1024).toFixed(0)} KB snapshot, lastmod ${lastmod[lang].date}${prev && prev.hash === hash ? ' (unchanged)' : ' (updated)'}`);
  await page.close();
}

writeFileSync(LASTMOD_FILE, JSON.stringify(lastmod, null, 2) + '\n');

// ---------------------------------------------------------------- OG images
const logo = 'data:image/png;base64,' + readFileSync(join(OUT, 'assets', 'favicon-192.png')).toString('base64');
const ogPage = await browser.newPage({ viewport: { width: SITE.ogWidth, height: SITE.ogHeight }, deviceScaleFactor: 1 });
for (const lang of langs) {
  const L = LOCALES[lang];
  const rtl = lang === 'ar';
  await ogPage.setContent(`<!DOCTYPE html><html lang="${lang}" dir="${rtl ? 'rtl' : 'ltr'}"><head><meta charset="utf-8">
<link rel="stylesheet" href="${base}/vendor/fonts.css">
<style>
*{box-sizing:border-box;margin:0}
body{width:${SITE.ogWidth}px;height:${SITE.ogHeight}px;display:flex;flex-direction:column;justify-content:space-between;
padding:76px 84px;background:${SITE.bgColor};font-family:Inter,'Noto Sans Arabic',system-ui,sans-serif;color:#456285;
background-image:radial-gradient(circle at 88% 8%,rgba(59,130,246,.20),transparent 46%),radial-gradient(circle at 4% 104%,rgba(139,92,246,.16),transparent 44%)}
.brand{display:flex;align-items:center;gap:18px}
.brand img{width:76px;height:76px;border-radius:20px}
.brand b{font-size:44px;font-weight:700;letter-spacing:-1px}
h1{font-size:${rtl ? 60 : 64}px;line-height:1.06;font-weight:300;letter-spacing:-2px;max-width:1000px;text-wrap:balance}
h1 strong{font-weight:700}
p{font-size:26px;line-height:1.45;color:#6F7F92;max-width:900px}
.foot{display:flex;align-items:center;gap:14px;font-size:22px;font-weight:600;color:#3B82F6}
.dot{width:9px;height:9px;border-radius:50%;background:#3B82F6}
</style></head><body>
<div class="brand"><img src="${logo}" alt=""><b>Wumbi</b></div>
<h1><strong>${L.ogTitle.replace(/^Wumbi\s*[—–-]\s*/, '')}</strong></h1>
<p>${L.description}</p>
<div class="foot"><span class="dot"></span>wumbi.app</div>
</body></html>`, { waitUntil: 'networkidle' });
  await ogPage.evaluate(() => document.fonts.ready);
  const shot = await ogPage.screenshot({ type: 'png' });
  // Palette PNG: ~250 KB of flat brand colour compresses to ~45 KB with no visible loss.
  const png = sharp ? await sharp(shot).png({ palette: true, quality: 88, effort: 10 }).toBuffer() : shot;
  writeFileSync(join(OG_DIR, `og-${lang}.png`), png);
  console.log(`  ${lang}: og-${lang}.png (${(png.length / 1024).toFixed(0)} KB)`);
}

await browser.close();
server.close();
console.log(`\nprerendered ${langs.length} locales → ${SNAP_DIR}/ and ${OG_DIR}/\nrun \`npm run build\` again to inject them.`);
