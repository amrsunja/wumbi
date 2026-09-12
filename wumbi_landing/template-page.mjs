// /free-budget-planner-template/ — a standalone static page (no dc-runtime, no React).
//
// Why it exists (COPY_AUDIT.md §4.2): five of the keywords Amir pulled from Google
// Trends are template-intent (budget planner excel, budget tracker template, excel
// finance tracker, budget planner book, wedding budget planner). Someone typing those
// wants a FILE, not an app. Pointing them at the homepage makes them bounce and teaches
// Google the homepage is a bad answer. So they get a real file, free, no email gate, and
// the app is offered at the bottom to the people who have just admitted they want to
// track a budget. The spreadsheet is our own work, not a copy of anyone else's.
import { SITE, TEMPLATE_PAGE as TP, APP } from './seo.config.mjs';

const esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const XLSX = '/assets/templates/Wumbi-Budget-Planner-Template.xlsx';
const URL = SITE.url + TP.path;

const TABS = [
  ['Start here', 'The legend and the four steps. Which cells are yours, which are formulas, and how to open it in Google Sheets.'],
  ['Categories', 'Twenty-eight categories grouped into Income, Needs, Wants and Savings. Rename any of them and the rename follows everywhere.'],
  ['Transactions', 'Six hundred rows ready to go. You fill in date, description, category, type and amount. Month, week and group work themselves out.'],
  ['Budget', 'Pick a month, type what you plan to spend, and the Actual column fills itself from your transactions. Overspending turns red on its own.'],
  ['Year', 'All twelve months side by side: income, expense, net, savings rate, the 50/30/20 split and every category. Nothing to fill in.'],
];

const STEPS = [
  ['Download it', 'One click, no email address, no sign-up. The file is yours.'],
  ['Open it', 'Excel, or upload it to Google Drive and open it in Sheets. Every formula and dropdown survives.'],
  ['Make the categories yours', 'The Categories tab is the only thing worth editing before you start.'],
  ['Fill in the yellow cells', 'Yellow means you type there. Everything else is a formula.'],
];

const FAQ = [
  ['Is this budget planner template really free?',
   'Yes. No email address, no sign-up, no watermark and no attribution required. Download it, copy it, change it, send it to whoever you like.'],
  ['Does it work in Google Sheets as well as Excel?',
   'Both. Upload the file to Google Drive and open it, or use File then Import inside Sheets. It deliberately avoids anything Sheets cannot read: no macros, no Power Query, no dynamic array formulas. Just SUMIFS, INDEX and MATCH.'],
  ['What is in the template?',
   'Five tabs: Start here, Categories, Transactions, Budget and Year. A monthly planned-versus-actual view, a twelve-month rollup, a savings rate, a 50/30/20 split and a per-category breakdown, all driven by formulas off a single transactions list.'],
  ['Can I use it as a weekly budget planner?',
   'Yes. Every transaction gets a week number automatically, so you can group or filter the Transactions tab by week. The Budget tab is built around a month because that is how rent, salaries and subscriptions actually land.'],
  ['Do I have to enter every transaction by hand?',
   'In a spreadsheet, yes. That is the honest limitation of every budget template ever made, and it is why most of them get abandoned in week two. If you want the same numbers without the typing, Wumbi does it on your phone in about three seconds per expense.'],
  ['What currency does it use?',
   'None in particular. Amounts are plain numbers, so set whatever currency format you like. If you deal in several currencies at once, a spreadsheet will fight you, and that is a fair reason to use an app instead.'],
];

export function templatePage() {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@graph': [
      {
        '@type': 'WebPage',
        '@id': URL + '#page',
        url: URL,
        name: TP.title,
        description: TP.description,
        inLanguage: 'en',
        isPartOf: { '@id': SITE.url + '/#website' },
        primaryImageOfPage: { '@type': 'ImageObject', url: SITE.url + '/assets/icon-512.png' },
      },
      {
        '@type': 'HowTo',
        '@id': URL + '#howto',
        name: 'How to use the free budget planner template',
        totalTime: 'PT10M',
        step: STEPS.map(([name, text], i) => ({ '@type': 'HowToStep', position: i + 1, name, text })),
      },
      {
        '@type': 'FAQPage',
        '@id': URL + '#faq',
        mainEntity: FAQ.map(([q, a]) => ({
          '@type': 'Question', name: q,
          acceptedAnswer: { '@type': 'Answer', text: a },
        })),
      },
      {
        '@type': 'SoftwareApplication',
        '@id': SITE.url + '/#app',
        name: SITE.name,
        applicationCategory: APP.category,
        operatingSystem: APP.platforms.join(', '),
        offers: { '@type': 'Offer', price: APP.price, priceCurrency: APP.currency, description: APP.offerDescription },
      },
    ],
  };

  return `<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>${esc(TP.title)} - ${SITE.name}</title>
<meta name="description" content="${esc(TP.description)}">
<meta name="keywords" content="${esc(TP.keywords.join(', '))}">
<meta name="robots" content="index,follow,max-image-preview:large,max-snippet:-1">
<meta name="theme-color" content="${SITE.themeColor}">
<link rel="canonical" href="${URL}">
<link rel="alternate" hreflang="x-default" href="${URL}">
<link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon-32.png">
<link rel="apple-touch-icon" href="/assets/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
<meta property="og:type" content="article">
<meta property="og:site_name" content="${SITE.name}">
<meta property="og:locale" content="en_US">
<meta property="og:url" content="${URL}">
<meta property="og:title" content="${esc(TP.title)}">
<meta property="og:description" content="${esc(TP.description)}">
<meta property="og:image" content="${SITE.url}/assets/icon-512.png">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="${esc(TP.title)}">
<meta name="twitter:description" content="${esc(TP.description)}">
<link rel="stylesheet" href="/vendor/fonts.css">
<style>
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
h1{font-family:Montserrat,Inter,sans-serif;font-weight:300;font-size:clamp(34px,5vw,54px);line-height:1.05;letter-spacing:-1.4px;margin:0 0 20px;text-wrap:balance}
h1 strong{font-weight:700}
h2{font-family:Montserrat,Inter,sans-serif;font-weight:300;font-size:clamp(26px,3.4vw,38px);line-height:1.1;letter-spacing:-.8px;margin:0 0 18px;text-wrap:balance}
h2 strong{font-weight:700}
h3{font-size:17px;font-weight:600;margin:0 0 6px;letter-spacing:-.2px}
p{margin:0 0 16px;color:#42505F;text-wrap:pretty}
.lead{font-size:19px;line-height:1.55;color:#42505F;max-width:62ch}
section{padding-block:56px}
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
summary:hover{color:#3B82F6}
details[open] summary{color:#3B82F6}
.faq-a{padding:0 22px 20px;font-size:15px;line-height:1.65;color:#6F7F92;max-width:70ch}
.appbox{background:#456285;color:#fff;border-radius:28px;padding:clamp(32px,5vw,56px);position:relative;overflow:hidden}
.appbox h2{color:#fff}
.appbox p{color:#D6E2F0}
.appbox .cta{background:#fff;color:#456285;box-shadow:none}
.appbox .cta:hover{background:#EEF3F8}
footer{border-top:1px solid rgba(174,194,212,.3);padding-block:28px;font-size:13px;color:#AEC2D4}
footer .wrap{display:flex;flex-wrap:wrap;gap:14px;justify-content:space-between;align-items:center;max-width:1120px}
footer a{color:#456285;font-weight:600}
@media (max-width:560px){section{padding-block:40px}.cta{width:100%;justify-content:center}}
</style>
</head>
<body>
<header class="bar">
  <div class="wrap">
    <a class="brand" href="/"><img src="/assets/app_logo.png" alt="" width="32" height="32">Wumbi</a>
    <a href="/" style="font-weight:600;font-size:14px;color:#456285">The app</a>
  </div>
</header>

<main class="wrap">

<section>
  <p class="kicker">Free download</p>
  <h1>Free budget planner template for <strong>Excel and Google Sheets</strong></h1>
  <p class="lead">Twelve months, planned against actual, a savings rate and a 50/30/20 split, all worked out by formulas from one list of transactions. No email address, no sign-up, no watermark. We built it ourselves and you can do whatever you like with it.</p>
  <p style="margin-top:28px"><a class="cta" href="${XLSX}" download>Download the template (.xlsx)</a></p>
  <p class="cta-note">Version ${TP.version}. Works in Microsoft Excel, Google Sheets, Numbers and LibreOffice. 48 KB.</p>
</section>

<section>
  <h2>What is <strong>inside</strong></h2>
  <ul class="grid">
    ${TABS.map(([t, d]) => `<li class="card"><h3>${esc(t)}</h3><p>${esc(d)}</p></li>`).join('\n    ')}
  </ul>
  <p style="margin-top:22px;font-size:15px;color:#6F7F92">Yellow cells are the ones you fill in. Everything else is a formula, and there are 2,277 of them. Nothing is locked, so you can pull it apart and see how it works.</p>
</section>

<section>
  <h2>How to <strong>use it</strong></h2>
  <ol class="steps">
    ${STEPS.map(([n, t]) => `<li><div><h3>${esc(n)}</h3><p style="margin:0;font-size:15px;color:#6F7F92">${esc(t)}</p></div></li>`).join('\n    ')}
  </ol>
</section>

<section>
  <h2>The honest bit about <strong>spreadsheets</strong></h2>
  <p>A budget planner spreadsheet is excellent at one thing and bad at another. It is excellent for planning a year: you can see twelve months at once, change one number and watch everything move.</p>
  <p>It is bad at the actual logging. To record a 4 euro coffee you have to be at a computer, find the file, find the row, and type four things. Nobody does that for long. Most budget templates are abandoned in the second week, and it is never because the template was badly made.</p>
  <p>So use this one for planning, and if you want the day-to-day part to survive, use something that takes three seconds while you are still standing at the till.</p>
</section>

<section>
  <div class="appbox">
    <h2>Wumbi does this <strong>on your phone</strong></h2>
    <p style="font-size:17px;max-width:52ch">Type the amount, tap Income or Expense, done. Roughly three seconds, and the screen stays open for the next one. No sign-up, no bank login, works with no internet, and the free plan is the whole product.</p>
    <p style="margin-top:24px"><a class="cta" href="/">See what Wumbi does</a></p>
  </div>
</section>

<section>
  <h2>Questions about <strong>the template</strong></h2>
  ${FAQ.map(([q, a]) => `<details><summary>${esc(q)}</summary><div class="faq-a">${esc(a)}</div></details>`).join('\n  ')}
</section>

</main>

<footer>
  <div class="wrap">
    <span>&copy; 2026 Wumbi</span>
    <nav style="display:flex;gap:18px;flex-wrap:wrap">
      <a href="/">Wumbi, the app</a>
      <a href="/#pricing">Free and premium</a>
      <a href="/#faq">FAQ</a>
      <a href="mailto:${SITE.email}">${SITE.email}</a>
    </nav>
  </div>
</footer>

<script type="application/ld+json">${JSON.stringify(jsonLd).replace(/</g, '\\u003c')}</script>
</body>
</html>
`;
}
