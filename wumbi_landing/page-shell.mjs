// Shared chrome for every standalone static page on the site: the template giveaway,
// About, Privacy, Terms and Press. No dc-runtime, no React, no JavaScript at all.
// One copy of the CSS so the pages cannot drift apart.
//
// Copy rules are the ones in COPY_AUDIT.md: no em dashes, no `·`, no `▲▼`, no "X. Not Y."
// headlines, informal second person, and no claim the product cannot keep.
import { SITE } from './seo.config.mjs';

export const esc = (s) => String(s)
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export const CSS = `
*{box-sizing:border-box}
body{margin:0;background:${SITE.bgColor};color:#101010;font-family:Inter,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;font-size:16px;line-height:1.6;-webkit-font-smoothing:antialiased}
a{color:#3B82F6;text-decoration:none}
a:hover{text-decoration:underline}
.wrap{max-width:880px;margin:0 auto;padding-inline:24px}
header.bar{border-bottom:1px solid rgba(174,194,212,.3);padding-block:16px;background:${SITE.bgColor}}
.bar .wrap{display:flex;align-items:center;justify-content:space-between;gap:16px;max-width:1120px}
.brand{display:flex;align-items:center;gap:10px;color:#456285;font-weight:700;font-size:17px}
.brand img{width:32px;height:32px;border-radius:9px}
.kicker{font-size:11px;font-weight:600;letter-spacing:1.2px;color:#AEC2D4;text-transform:uppercase;margin:0 0 14px}
h1{font-family:Montserrat,Inter,sans-serif;font-weight:300;font-size:clamp(32px,4.6vw,50px);line-height:1.06;letter-spacing:-1.3px;margin:0 0 20px;text-wrap:balance}
h1 strong{font-weight:700}
h2{font-family:Montserrat,Inter,sans-serif;font-weight:300;font-size:clamp(24px,3.2vw,34px);line-height:1.12;letter-spacing:-.7px;margin:0 0 18px;text-wrap:balance}
h2 strong{font-weight:700}
h3{font-size:17px;font-weight:600;margin:0 0 6px;letter-spacing:-.2px;color:#456285}
p{margin:0 0 16px;color:#42505F;text-wrap:pretty}
.lead{font-size:19px;line-height:1.55;color:#42505F;max-width:62ch}
section{padding-block:52px}
section+section{border-top:1px solid rgba(174,194,212,.25)}
.cta{display:inline-flex;align-items:center;gap:12px;background:#3B82F6;color:#fff;font-weight:700;font-size:17px;padding:18px 30px;border-radius:999px;box-shadow:0 18px 34px -18px rgba(59,130,246,.85)}
.cta:hover{text-decoration:none;background:#2f74e0}
.cta-note{margin-top:14px;font-size:14px;color:#6F7F92}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:18px;margin:0;padding:0;list-style:none}
.card{background:rgba(255,255,255,.75);border:1px solid rgba(174,194,212,.3);border-radius:20px;padding:22px 24px}
.card p{margin:0;font-size:15px;line-height:1.55;color:#6F7F92}
ol.steps{counter-reset:s;list-style:none;margin:0;padding:0;display:flex;flex-direction:column;gap:16px}
ol.steps li{counter-increment:s;display:flex;gap:16px;align-items:flex-start}
ol.steps li::before{content:counter(s);flex-shrink:0;width:30px;height:30px;border-radius:50%;background:rgba(59,130,246,.12);color:#3B82F6;font-weight:700;font-size:14px;display:flex;align-items:center;justify-content:center;margin-top:2px}
details{background:rgba(255,255,255,.75);border:1px solid rgba(174,194,212,.3);border-radius:18px;margin-bottom:12px;overflow:hidden}
summary{cursor:pointer;list-style:none;padding:18px 22px;font-size:16px;font-weight:600;color:#456285}
summary::-webkit-details-marker{display:none}
summary:hover,details[open] summary{color:#3B82F6}
.faq-a{padding:0 22px 20px;font-size:15px;line-height:1.65;color:#6F7F92;max-width:70ch}
.appbox{background:#456285;color:#fff;border-radius:28px;padding:clamp(32px,5vw,56px);position:relative;overflow:hidden}
.appbox h2{color:#fff}
.appbox p{color:#D6E2F0}
.appbox .cta{background:#fff;color:#456285;box-shadow:none}
.appbox .cta:hover{background:#EEF3F8}
.prose{max-width:70ch}
.prose h2{margin-top:44px;font-size:clamp(22px,2.6vw,28px)}
.prose h2:first-child{margin-top:0}
.prose h3{margin-top:28px}
.prose ul{margin:0 0 16px;padding-inline-start:22px;color:#42505F}
.prose li{margin-bottom:8px}
.prose li::marker{color:#AEC2D4}
.meta{font-size:14px;color:#6F7F92;border-inline-start:3px solid rgba(59,130,246,.35);padding-inline-start:16px;margin:0 0 34px}
.meta strong{color:#456285}
.note{background:rgba(59,130,246,.07);border:1px solid rgba(59,130,246,.22);border-radius:16px;padding:18px 22px;font-size:15px;line-height:1.6;color:#42505F;margin:0 0 24px}
.note p:last-child{margin-bottom:0}
.kv{display:grid;grid-template-columns:minmax(120px,180px) 1fr;gap:10px 20px;font-size:15px;margin:0 0 20px}
.kv dt{font-weight:600;color:#456285}
.kv dd{margin:0;color:#42505F}
.toc{display:flex;flex-wrap:wrap;gap:10px;margin:0 0 8px;padding:0;list-style:none}
.toc a{display:inline-block;border:1px solid rgba(174,194,212,.45);border-radius:999px;padding:7px 14px;font-size:13px;font-weight:600;color:#456285;background:rgba(255,255,255,.5)}
.toc a:hover{text-decoration:none;border-color:#3B82F6;color:#3B82F6}
footer{border-top:1px solid rgba(174,194,212,.3);padding-block:28px;font-size:13px;color:#AEC2D4}
footer .wrap{display:flex;flex-wrap:wrap;gap:14px;justify-content:space-between;align-items:center;max-width:1120px}
footer a{color:#456285;font-weight:600}
footer nav{display:flex;gap:18px;flex-wrap:wrap}
@media (max-width:560px){section{padding-block:36px}.cta{width:100%;justify-content:center}.kv{grid-template-columns:1fr;gap:2px 0}.kv dd{margin-bottom:10px}}
`.trim();

const FOOT_LINKS = [
  ['/', 'Wumbi, the app'],
  ['/about/', 'About'],
  ['/free-budget-planner-template/', 'Budget template'],
  ['/privacy/', 'Privacy'],
  ['/terms/', 'Terms'],
  ['/press/', 'Press'],
];

/**
 * @param {object} o
 * @param {string} o.path      route with leading and trailing slash, e.g. '/about/'
 * @param {string} o.title     <title> without the site name
 * @param {string} o.description meta description
 * @param {string[]} [o.keywords]
 * @param {string} o.body      the <main> inner HTML
 * @param {object} [o.jsonLd]  a @graph object, already shaped
 * @param {string} [o.ogType]  defaults to 'article'
 */
export function shell({ path, title, description, keywords = [], body, jsonLd, ogType = 'article' }) {
  const url = SITE.url + path;
  const here = (p) => p === path;
  return `<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>${esc(title)} - ${SITE.name}</title>
<meta name="description" content="${esc(description)}">
${keywords.length ? `<meta name="keywords" content="${esc(keywords.join(', '))}">` : ''}
<meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1">
<meta name="theme-color" content="${SITE.themeColor}">
<link rel="canonical" href="${url}">
<link rel="alternate" hreflang="x-default" href="${url}">
<link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon-32.png">
<link rel="apple-touch-icon" href="/assets/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta property="og:type" content="${ogType}">
<meta property="og:site_name" content="${SITE.name}">
<meta property="og:locale" content="en_US">
<meta property="og:url" content="${url}">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(description)}">
<meta property="og:image" content="${SITE.url}/assets/og/og-en.png">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="${esc(title)}">
<meta name="twitter:description" content="${esc(description)}">
<link rel="stylesheet" href="/vendor/fonts.css">
<style>${CSS}</style>
</head>
<body>
<header class="bar">
  <div class="wrap">
    <a class="brand" href="/"><img src="/assets/app_logo.png" alt="" width="32" height="32">Wumbi</a>
    <a href="/" style="font-weight:600;font-size:14px;color:#456285">The app</a>
  </div>
</header>

<main class="wrap">
${body}
</main>

<footer>
  <div class="wrap">
    <span>&copy; 2026 Wumbi</span>
    <nav>${FOOT_LINKS.filter(([p]) => !here(p)).map(([p, t]) => `<a href="${p}">${t}</a>`).join('')}
      <a href="mailto:${SITE.email}">${SITE.email}</a></nav>
  </div>
</footer>
${jsonLd ? `<script type="application/ld+json">${JSON.stringify(jsonLd).replace(/</g, '\\u003c')}</script>` : ''}
</body>
</html>
`;
}
