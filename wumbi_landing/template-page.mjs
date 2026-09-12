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
import { shell, esc } from './page-shell.mjs';
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

  const body = `

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

`;

  return shell({
    path: TP.path,
    body,
    title: TP.title,
    description: TP.description,
    keywords: TP.keywords,
    jsonLd,
  });
}
