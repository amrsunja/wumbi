// /about/, /privacy/, /terms/ and /press/ — four standalone static pages.
//
// English only, on purpose. The marketing page ships in 7 locales; a privacy policy and
// terms of use do not, because every translation of a legal document is a new place for
// a mistranslated term to mean something you did not agree to. One authoritative English
// version is the normal, defensible choice for a small app. About and Press can be
// localised later without that risk.
//
// Everything factual here was checked against the app source on 2026-09-12:
//   - sqflite_sqlcipher + flutter_secure_storage      → AES-256 DB, key in Keychain/Keystore
//   - no analytics, crash, ad or attribution SDK in pubspec.yaml or lib/
//   - no runtime permissions in Info.plist or AndroidManifest.xml
//   - currency_converter → fawazahmed0 currency-api over cdn.jsdelivr.net,
//     fallback currency-api.pages.dev, no API key
//   - FxService: 12 h cache, stale at 24 h
//   - CurrencyConverter.getMyCurrency() reads the DEVICE LOCALE, not an IP lookup
//   - currency_type.dart: 61 fiat + BTC/ETH/USDT = 64
// If any of that changes in the app, change it here in the same commit.
import { SITE, APP, LEGAL } from './seo.config.mjs';
import { shell, esc } from './page-shell.mjs';

const CONTACT = LEGAL.privacyContact || SITE.email;
const UPDATED = LEGAL.effectiveDate;
const pretty = (d) => new Date(d + 'T00:00:00Z').toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' });

// Rendered wherever a fact is genuinely not settled yet. Better an honest gap than an
// invented company name on a page people are supposed to be able to rely on.
const pending = (what) =>
  `<em style="color:#6F7F92">${esc(what)} is not published yet. Ask us at <a href="mailto:${SITE.email}">${SITE.email}</a> and we will tell you.</em>`;

const toc = (items) => `<ul class="toc">${items.map(([h, t]) => `<li><a href="#${h}">${esc(t)}</a></li>`).join('')}</ul>`;

/* ------------------------------------------------------------------ about */
export function aboutPage() {
  const body = `
<section>
  <p class="kicker">About</p>
  <h1>We built the budgeting app <strong>we kept failing to use</strong></h1>
  <p class="lead">Wumbi exists because every other budgeting app died on us in the second week. Not because they were badly made. Because logging a coffee took forty seconds and nobody does that forty times a month.</p>
</section>

<section>
  <div class="prose">
    <h2>The problem, stated plainly</h2>
    <p>You install a budgeting app in January with real intentions. You categorise everything for nine days. Then one evening you are tired, you skip a day, the backlog looks like homework, and you never open it again. By March you could not say where your money went, and the app is still on your phone quietly making you feel bad.</p>
    <p>Almost every fix on the market attacks the wrong end of this. They add automatic bank imports, which means handing over your bank login and then correcting a machine's guesses. They add smarter categories, which is more structure to maintain. They add streaks and badges, which is a reminder that you failed.</p>

    <h2>What we did instead</h2>
    <p>We made the logging fast enough that there is nothing to fall behind on. Open Wumbi, type the amount, tap Income or Expense. About three seconds, and the screen stays open for the next one. No confirmation screen, no category picker, no Save button, because there is nothing left to confirm.</p>
    <p>Instead of categories you type tags as you go, the way you would write a note to yourself. They create themselves. Later a tag map shows you which ones keep moving money together, which is a thing a category list can never tell you.</p>

    <h2>Why your data stays on your phone</h2>
    <p>Your transaction history says where you live, what you eat, who you see, what you are worried about and what you are saving for. That is not a normal thing to upload to a stranger's server so that a budgeting app can show you a pie chart.</p>
    <p>So Wumbi keeps it on the device, in an encrypted database, and asks for no account at all. You do not need to trust us, because we do not have it.</p>
    <p>Premium will offer an encrypted backup and, for people who want automation, an optional bank connection. Both are switches you turn on. Neither is ever a step you are forced through to use the app, and the free version will never require an account.</p>

    <h2>How Wumbi makes money</h2>
    <p>The free app is the product, not a trial. It has unlimited transactions, tags, the tag map, 64 currencies, charts, subscriptions and full offline use, with no ads.</p>
    <p>Premium adds things for people who have been using Wumbi for months and want more out of it: backup and restore, optional bank sync, import and export, deeper analytics, savings goals, widgets, unlimited wallets and some cosmetic fun. Nothing that is basic sits behind it. Pricing lands with the app.</p>

    <h2>Who is behind it</h2>
    <p>Wumbi is a small independent project, not a venture-funded startup with a growth target. ${LEGAL.operator ? `It is operated by ${esc(LEGAL.operator)}.` : pending('The operating entity')}</p>
    <p>There are no investors to satisfy, which is the reason we can afford to not want your bank login.</p>

    <h2>Where it is going</h2>
    <p>iPhone and Android first, in seven languages, with full right-to-left layout for Arabic. Then premium, then whatever the first few thousand people actually ask for. If you want to be told once, on the day it launches, the waitlist is on the front page and it sends exactly one email.</p>
  </div>
</section>

<section>
  <div class="appbox">
    <h2>Three seconds per expense. <strong>See if that holds up</strong></h2>
    <p style="font-size:17px;max-width:52ch">The front page shows the whole app: the numpad, the tag map, the charts, and what the free and premium plans actually contain.</p>
    <p style="margin-top:24px"><a class="cta" href="/">Look at Wumbi</a></p>
  </div>
</section>`;

  return shell({
    path: '/about/',
    body,
    title: 'About Wumbi',
    description: 'Why Wumbi exists: budgeting apps die in week two because logging takes too long. Wumbi takes three seconds per expense and keeps your data on your phone.',
    keywords: ['about wumbi', 'private budget app', 'local budget app', 'indie budgeting app', 'budget app that keeps data on device'],
    jsonLd: {
      '@context': 'https://schema.org',
      '@graph': [
        { '@type': 'AboutPage', '@id': SITE.url + '/about/#page', url: SITE.url + '/about/', name: 'About Wumbi', inLanguage: 'en', isPartOf: { '@id': SITE.url + '/#website' } },
        { '@type': 'Organization', '@id': SITE.url + '/#org', name: SITE.name, url: SITE.url, email: SITE.email, logo: SITE.url + '/assets/icon-512.png' },
      ],
    },
  });
}

/* ---------------------------------------------------------------- privacy */
export function privacyPage() {
  const body = `
<section>
  <p class="kicker">Privacy</p>
  <h1>Privacy policy</h1>
  <p class="meta"><strong>Last updated:</strong> ${pretty(UPDATED)}<br>
  <strong>Applies to:</strong> the Wumbi mobile app for iPhone and Android, and this website.<br>
  <strong>Short version:</strong> the free app has no account and sends your transactions nowhere. The only thing it ever fetches is an exchange rate.</p>
  ${toc([['collect', 'What we collect'], ['device', 'On your device'], ['rates', 'Exchange rates'], ['website', 'This website'], ['waitlist', 'The waitlist'], ['premium', 'Premium'], ['rights', 'Your rights'], ['children', 'Children'], ['changes', 'Changes'], ['contact', 'Contact']])}
</section>

<section>
  <div class="prose">
    <h2 id="collect">What we collect</h2>
    <p>From the free app: nothing. There is no sign-up, no email address, no password, no device identifier, no advertising ID and no profile. We do not know who you are, how often you open the app, or that you installed it.</p>
    <p>This is not a promise we are asking you to take on faith. The app ships with no analytics SDK, no crash-reporting SDK, no advertising SDK and no attribution SDK, and it declares no runtime permissions: no location, no contacts, no camera, no photos.</p>

    <h2 id="device">What lives on your device</h2>
    <p>Everything you type into Wumbi stays on the phone:</p>
    <ul>
      <li>your transactions, amounts, descriptions and tags</li>
      <li>your wallets and their currencies</li>
      <li>your subscriptions and upcoming payments</li>
      <li>your settings, including language, theme and base currency</li>
      <li>a local cache of exchange rates</li>
    </ul>
    <p>It is stored in a database encrypted with AES-256. The encryption key is generated on your device and kept in the platform's secure storage, which is the iOS Keychain or the Android Keystore. We never see the key and there is no copy of it anywhere else, which also means we cannot recover your data if you lose the phone.</p>
    <p>Deleting the app removes the database. Inside the app, one tap in Settings wipes everything immediately.</p>

    <h2 id="rates">Exchange rates, the one request the app makes</h2>
    <p>Wumbi converts between currencies, so it needs rates. It gets them from the open-source <a href="https://github.com/fawazahmed0/exchange-api" rel="noopener nofollow" target="_blank">currency-api</a> project, which is served from public content delivery networks (cdn.jsdelivr.net, with a fallback on currency-api.pages.dev). No API key, no account, no registration.</p>
    <p>That request asks for a currency pair and contains nothing else. No transaction, no amount, no description, no tag, no identifier. Like any request to any website, the CDN serving it can see your device's IP address and the time, because that is how the internet delivers a response. We receive none of it: the request does not pass through any Wumbi server, because there is no Wumbi server.</p>
    <p>Rates are cached on the device for 12 hours, so the app makes this request rarely, and it works completely offline on the cached values. Every transaction also stores the rate it was created with, so your history never changes when rates move later.</p>
    <p>When you first set up the app, Wumbi suggests a currency based on your device's language and region settings. That check happens on the phone. It is not an IP lookup and nothing is sent anywhere.</p>

    <h2 id="website">This website</h2>
    <p>wumbi.app serves static pages. As of ${pretty(UPDATED)} it sets no cookies, runs no analytics, embeds no tracking pixel and loads no third-party fonts or scripts: the fonts are served from our own domain precisely so your browser does not have to talk to anyone else.</p>
    <p>Your browser stores two things locally, on your device only, which never reach us: the language you picked, so the site opens in it next time, and a note that you joined the waitlist, so the form does not ask twice. You can clear both by clearing site data.</p>
    <p>Our host keeps standard server logs (IP address, time, page requested, user agent) for security and troubleshooting, as every web host does.</p>
    <p>If we ever add analytics it will be a cookieless, privacy-preserving kind, and this page will say so before it goes live.</p>

    <h2 id="waitlist">If you join the waitlist</h2>
    <p>You give us an email address. We use it for exactly one thing: one message on the day Wumbi launches. No newsletter, no drip sequence, no sharing it, no selling it, and no passing it to advertisers.</p>
    <p>The form is delivered by <a href="https://web3forms.com" rel="noopener nofollow" target="_blank">Web3Forms</a>, which processes the submission and forwards it to us by email. Your address is also stored in your own browser so the form knows you already signed up.</p>
    <p>Under the GDPR the lawful basis is your consent, given by submitting the form. Reply to any message from us, or write to <a href="mailto:${CONTACT}">${CONTACT}</a>, and we will delete your address. We keep it until launch, or until you ask, whichever comes first.</p>

    <h2 id="premium">Premium, which has not launched yet</h2>
    <p>Everything above describes Wumbi as it exists today. Premium will add two features that change the picture, and both are optional and off until you switch them on:</p>
    <ul>
      <li><strong>Encrypted backup.</strong> Creating an account so your data survives a lost phone. Only then does anything leave the device, and it leaves encrypted.</li>
      <li><strong>Bank sync.</strong> Connecting a bank so transactions arrive without typing. This involves a regulated third-party provider, and it will have its own clearly written section here.</li>
    </ul>
    <p>The free app will never require an account, and neither feature will ever be switched on without you doing it. This page will be rewritten, and dated, before either ships.</p>

    <h2 id="rights">Your rights</h2>
    <p>If you are in the EU, the EEA or the UK, the GDPR gives you the right to access, correct, delete and port your personal data, to object to processing, and to complain to your national data protection authority.</p>
    <p>For the app, those rights are mostly something you exercise directly: the data is on your phone, you can read it, edit it and delete it without asking anyone. We hold none of it, so there is nothing for us to hand over or erase.</p>
    <p>For the waitlist email address, write to <a href="mailto:${CONTACT}">${CONTACT}</a> and we will act on it.</p>

    <h2 id="children">Children</h2>
    <p>Wumbi is not directed at children under 13, and we do not knowingly collect anything from them. Since the app collects nothing from anyone, there is nothing to delete, but if you believe a child has given us a waitlist email address, tell us and it goes.</p>

    <h2 id="changes">Changes to this policy</h2>
    <p>When this changes in substance, the date at the top changes and the new version explains what moved. We will not quietly widen what we collect and leave the date alone.</p>

    <h2 id="contact">Contact</h2>
    <dl class="kv">
      <dt>Email</dt><dd><a href="mailto:${CONTACT}">${CONTACT}</a></dd>
      <dt>Operator</dt><dd>${LEGAL.operator ? esc(LEGAL.operator) : pending('The operating entity')}</dd>
      <dt>Address</dt><dd>${LEGAL.address ? esc(LEGAL.address) : pending('A postal address')}</dd>
    </dl>
  </div>
</section>`;

  return shell({
    path: '/privacy/',
    body,
    title: 'Privacy policy',
    description: 'Wumbi collects nothing. No account, no analytics, no tracking. Your transactions stay in an AES-256 encrypted database on your phone. The only request the app makes is for an exchange rate.',
    keywords: ['wumbi privacy policy', 'private budget app', 'budget app that does not collect data', 'encrypted expense tracker privacy'],
    jsonLd: {
      '@context': 'https://schema.org',
      '@graph': [
        { '@type': 'WebPage', '@id': SITE.url + '/privacy/#page', url: SITE.url + '/privacy/', name: 'Privacy policy', inLanguage: 'en', dateModified: UPDATED, isPartOf: { '@id': SITE.url + '/#website' } },
      ],
    },
  });
}

/* ------------------------------------------------------------------ terms */
export function termsPage() {
  const law = LEGAL.governingLaw;
  const body = `
<section>
  <p class="kicker">Terms</p>
  <h1>Terms of use</h1>
  <p class="meta"><strong>Last updated:</strong> ${pretty(UPDATED)}<br>
  <strong>Applies to:</strong> the Wumbi mobile app and wumbi.app.<br>
  <strong>Short version:</strong> use the app for your own money, do not break it or resell it, and understand that it is a notebook, not a financial adviser.</p>
  ${toc([['agreement', 'The agreement'], ['licence', 'Your licence'], ['data', 'Your data'], ['plans', 'Free and premium'], ['fair', 'Fair use'], ['advice', 'Not financial advice'], ['availability', 'Availability'], ['ip', 'Our content'], ['liability', 'Liability'], ['ending', 'Ending this'], ['law', 'Governing law'], ['contact', 'Contact']])}
</section>

<section>
  <div class="prose">
    <h2 id="agreement">The agreement</h2>
    <p>These terms are between you and the operator of Wumbi. By installing the app or using this website you accept them. If you do not, do not use Wumbi, which costs you nothing since there is no account to close.</p>
    <p>You need to be old enough to enter a contract where you live, and at least 13.</p>

    <h2 id="licence">Your licence to use Wumbi</h2>
    <p>You get a personal, non-exclusive, non-transferable, revocable licence to use Wumbi on devices you own or control, for your own purposes, personal or business. That is it, and it is enough.</p>
    <p>You may not resell, rent, sublicense or redistribute the app, take it apart to build a competing product, remove the branding, or attempt to bypass the premium tier. Reverse engineering is permitted only where your local law says it is, whatever this paragraph says.</p>

    <h2 id="data">Your data is yours, and it is your responsibility</h2>
    <p>Everything you put into Wumbi belongs to you. We claim no ownership of it and, on the free plan, we do not have a copy of it. See the <a href="/privacy/">privacy policy</a> for what that means in detail.</p>
    <p>The other side of that is unavoidable and we would rather be blunt about it: <strong>if you lose your phone, or delete the app, or reset the data, your Wumbi history is gone and we cannot get it back.</strong> There is no server copy to restore from. That is the direct consequence of encrypting everything on your device and holding no key. If losing your history matters to you, wait for the premium backup or export your data regularly once export ships.</p>

    <h2 id="plans">Free and premium</h2>
    <p>Wumbi is free to use. The free plan includes unlimited transactions, tags, the tag map, 64 currencies, search, charts, subscriptions, offline use and encryption, with no advertising.</p>
    <p>A premium plan will add optional features at launch. When it exists, it will be sold through the Apple App Store or Google Play, and their billing, renewal, refund and cancellation rules will apply to it as well as these terms. Prices, trial terms and what exactly each plan contains will be stated in the app before you pay anything.</p>
    <p>We may change what is in each plan. We will not move a feature out of the free plan and behind payment after you have come to rely on it.</p>

    <h2 id="fair">Fair use</h2>
    <p>Do not use Wumbi to break the law, to launder money, to record someone else's finances without their knowledge, or to attack the service or the people who run it. Do not hammer the exchange-rate providers through the app. Do not upload anything to us, since there is nowhere to upload it.</p>

    <h2 id="advice">Wumbi is not financial advice</h2>
    <p>Wumbi records numbers you type and does arithmetic on them. It is a notebook with a calculator, not a financial adviser, an accountant or a tax tool, and nothing in it is a recommendation to do anything with your money.</p>
    <p>Exchange rates come from a free public source and are indicative. They are not dealing rates, they are cached for up to 12 hours, and they will not match what your bank or card issuer actually charges you. Do not use them to settle a real transaction, file a tax return, or make a decision that depends on a precise figure. Check your own numbers.</p>

    <h2 id="availability">Availability</h2>
    <p>The app runs on your phone, so it keeps working whether or not we do. The exchange-rate service, the website and the waitlist depend on third parties and can break, and we do not promise any level of uptime for them.</p>
    <p>We may change, suspend or discontinue any part of Wumbi. If we ever discontinue the app entirely, the copy on your phone keeps working with the data already on it, because it does not need us.</p>

    <h2 id="ip">Our content</h2>
    <p>The Wumbi name, logo, mascot, interface, copy and code are ours and stay ours. The budget planner spreadsheet we give away on <a href="/free-budget-planner-template/">this page</a> is the exception: you can download it, change it, use it commercially and pass it on, with no attribution required.</p>

    <h2 id="liability">Liability</h2>
    <p>Wumbi is provided as it is, without warranties of any kind, to the fullest extent the law where you live allows.</p>
    <p>We are not liable for money you lose because a number in Wumbi was wrong, a rate was stale, the app was unavailable, or your data was deleted from your device. We are not liable for indirect or consequential loss. Where liability cannot be excluded, it is limited to the amount you have actually paid us in the twelve months before the claim, which for a free user is nothing.</p>
    <p>None of this limits rights you have as a consumer that cannot be waived, and in the EU and the UK there are several. Those rights stand regardless of what this section says.</p>

    <h2 id="ending">Ending this</h2>
    <p>You end it by deleting the app. Nothing to cancel, nobody to email, no account to close.</p>
    <p>We may end it if you seriously break these terms, which in practice means attacking the service or redistributing the app.</p>

    <h2 id="law">Governing law</h2>
    ${law
      ? `<p>These terms are governed by the law of ${esc(law)}, and the courts of ${esc(law)} have jurisdiction over any dispute. If you are a consumer, this does not deprive you of the protection of the mandatory law of the country where you live, and you can also bring a claim in your own local courts.</p>`
      : `<p class="note">${pending('The governing law and competent courts')} If you are a consumer in the EU or the UK, the mandatory consumer law of the country where you live protects you regardless, and you can bring a claim in your own local courts.</p>`}
    <p>If any part of these terms turns out to be unenforceable, the rest still stands.</p>

    <h2 id="contact">Contact</h2>
    <dl class="kv">
      <dt>Email</dt><dd><a href="mailto:${SITE.email}">${SITE.email}</a></dd>
      <dt>Operator</dt><dd>${LEGAL.operator ? esc(LEGAL.operator) : pending('The operating entity')}</dd>
      <dt>Address</dt><dd>${LEGAL.address ? esc(LEGAL.address) : pending('A postal address')}</dd>
    </dl>
  </div>
</section>`;

  return shell({
    path: '/terms/',
    body,
    title: 'Terms of use',
    description: 'The terms for using Wumbi: a personal licence, your data stays yours and stays on your phone, what the free and premium plans cover, and why exchange rates are indicative.',
    keywords: ['wumbi terms of use', 'budget app terms', 'terms and conditions'],
    jsonLd: {
      '@context': 'https://schema.org',
      '@graph': [
        { '@type': 'WebPage', '@id': SITE.url + '/terms/#page', url: SITE.url + '/terms/', name: 'Terms of use', inLanguage: 'en', dateModified: UPDATED, isPartOf: { '@id': SITE.url + '/#website' } },
      ],
    },
  });
}

/* ------------------------------------------------------------------ press */
export function pressPage() {
  const FACTS = [
    ['What it is', 'A budgeting app for iPhone and Android that logs an expense in about three seconds, using tags instead of categories.'],
    ['Status', 'Pre-launch. Waitlist open at wumbi.app.'],
    ['Price', 'Free, with no ads. A premium plan arrives at launch.'],
    ['Account', 'Not required. The free app has no sign-up and no bank connection.'],
    ['Storage', 'An AES-256 encrypted database on the device, key held in the iOS Keychain or Android Keystore.'],
    ['Currencies', '64, including Bitcoin, Ethereum and USDT to 8 decimals.'],
    ['Offline', 'Fully usable with no internet. Rates cached for 12 hours.'],
    ['Languages', 'English, French, German, Dutch, Turkish, Russian and Arabic, with full right-to-left layout.'],
    ['Contact', SITE.email],
  ];

  const ANGLES = [
    ['The three-second claim is the whole product', 'Most budgeting apps fail on retention, not features. Wumbi is an argument that the fix is logging speed, not smarter automation. That is a testable claim and worth testing.'],
    ['A finance app with no account, deliberately', 'No sign-up, no bank link, no server. Unusual enough in personal finance to be worth asking about, and it has real consequences: lose the phone on the free plan and the data is gone.'],
    ['Tags instead of categories', 'Free-form tags typed inline, plus a force-directed map showing which tags move money together. A different mental model from the category tree every competitor uses.'],
    ['64 currencies including crypto', 'Per-wallet currencies, a converted total, and every transaction storing the rate it was made with so history does not drift.'],
  ];

  const body = `
<section>
  <p class="kicker">Press</p>
  <h1>Press and <strong>media kit</strong></h1>
  <p class="lead">Everything you need to write about Wumbi without emailing us first. If you do need something specific, a screenshot at a particular size, a quote, an early build, we answer quickly.</p>
  <p style="margin-top:24px"><a class="cta" href="mailto:${SITE.email}?subject=Press%20enquiry%20about%20Wumbi">Email us about a story</a></p>
</section>

<section>
  <h2>The <strong>facts</strong></h2>
  <dl class="kv">
    ${FACTS.map(([k, v]) => `<dt>${esc(k)}</dt><dd>${esc(v)}</dd>`).join('\n    ')}
  </dl>
  <p style="font-size:15px;color:#6F7F92">Every number here is checkable in the app. If you find one that is wrong, tell us and we will fix it on this page the same day.</p>
</section>

<section>
  <h2>How to <strong>describe Wumbi</strong></h2>
  <h3>One line</h3>
  <p>Wumbi is a free budgeting app that logs an expense in about three seconds and keeps everything encrypted on your phone.</p>
  <h3>One paragraph</h3>
  <p>Wumbi is a budgeting app for iPhone and Android built around a single idea: that people abandon budgeting apps because logging is slow, not because the charts are bad. You type an amount, tap Income or Expense, and it is saved in about three seconds, with the screen already waiting for the next one. Instead of maintaining a category tree you type free-form tags as you go, and a tag map later shows which of them move money together. The free app needs no account and no bank connection, works with no internet, supports 64 currencies including crypto, and stores everything in an AES-256 encrypted database on the device itself.</p>
  <h3>Boilerplate</h3>
  <p>Wumbi is an independent app project. ${LEGAL.operator ? `It is operated by ${esc(LEGAL.operator)}.` : pending('The operating entity')} It is not venture funded.</p>
</section>

<section>
  <h2>Story <strong>angles</strong></h2>
  <ul class="grid">
    ${ANGLES.map(([t, d]) => `<li class="card"><h3>${esc(t)}</h3><p>${esc(d)}</p></li>`).join('\n    ')}
  </ul>
</section>

<section>
  <h2>Assets and <strong>usage</strong></h2>
  <p>Logo, mascot and product screenshots are available on request, in whatever sizes and formats you need. Email <a href="mailto:${SITE.email}">${SITE.email}</a> and say what the layout calls for.</p>
  <h3>What you may do</h3>
  <ul class="prose">
    <li>Use the Wumbi name, logo and screenshots in articles, reviews and roundups about Wumbi.</li>
    <li>Crop screenshots and place the logo on your own backgrounds.</li>
    <li>Quote anything on this website without asking.</li>
  </ul>
  <h3>What we ask you not to do</h3>
  <ul class="prose">
    <li>Redraw, recolour or restretch the logo and the mascot.</li>
    <li>Use them to imply we endorse a product, a service or a ranking we did not endorse.</li>
    <li>Mock up screenshots showing features Wumbi does not have. Ask us and we will make you a real one.</li>
  </ul>
</section>

<section>
  <div class="appbox">
    <h2>Want an <strong>early build</strong>?</h2>
    <p style="font-size:17px;max-width:52ch">If you are writing something before launch, say so in your email and we will get you access ahead of the public release.</p>
    <p style="margin-top:24px"><a class="cta" href="mailto:${SITE.email}?subject=Early%20access%20request%20(press)">Ask for early access</a></p>
  </div>
</section>`;

  return shell({
    path: '/press/',
    body,
    title: 'Press and media kit',
    description: 'Press kit for Wumbi: the facts, ready-to-use descriptions, story angles, asset usage rules and a direct contact for early access before launch.',
    keywords: ['wumbi press kit', 'wumbi media kit', 'budget app press'],
    jsonLd: {
      '@context': 'https://schema.org',
      '@graph': [
        { '@type': 'WebPage', '@id': SITE.url + '/press/#page', url: SITE.url + '/press/', name: 'Press and media kit', inLanguage: 'en', isPartOf: { '@id': SITE.url + '/#website' } },
        {
          '@type': 'SoftwareApplication', '@id': SITE.url + '/#app', name: SITE.name,
          applicationCategory: APP.category, operatingSystem: APP.platforms.join(', '),
          featureList: APP.features,
          offers: { '@type': 'Offer', price: APP.price, priceCurrency: APP.currency, description: APP.offerDescription },
        },
      ],
    },
  });
}

export const STATIC_PAGES = [
  ['/about/', aboutPage],
  ['/privacy/', privacyPage],
  ['/terms/', termsPage],
  ['/press/', pressPage],
];
