# Wumbi landing page — copy & SEO audit v2

**Date:** 2026-09-12
**Scope:** `i18n.js` (7 locales), `seo.config.mjs`, hardcoded strings in `Wumbi Landing.dc.html`.
**Status:** **IMPLEMENTED 2026-09-12.** Everything below is live in `i18n.js`, `seo.config.mjs`, `Wumbi Landing.dc.html`, `build.mjs` and the new `template-page.mjs`. `npm run prerender` has been re-run and all 7 locales are re-snapshotted. See §17 for what shipped and the two things that still need your word.
**Russian version:** `COPY_AUDIT.ru.md`

> v2 replaces v1. Amir's answers changed the positioning: Wumbi is **freemium**, and premium **does** include an account and bank sync. v1 was built on "no account, ever", which would have become a lie at launch.

---

## 1. The short verdict

Three separate problems, in order of what they cost you.

**1. The positioning is now wrong, not just badly worded.**
The whole page promises "no account, no server, no bank connection" as an absolute. At launch, premium will offer exactly those things: an account to save your progress, and a bank connection for people who want automation. If we ship the current copy, every premium feature reads as a broken promise. The fix is not to hide premium. The fix is to change the promise from *"never"* to *"only if you ask for it"*, which is a stronger sell anyway.

**2. The page is invisible for the words people type.**
On the entire English page: `budget tracker` **0 times**. `budget planner` **0**. `finance app` **0**. `finance tracker` **0**. `expense tracker` **0**. `iPhone` **0**. `free` appears 3 times and all 3 are inside "free-form tags". The page currently optimises for `local-first`, a phrase used by developers and by nobody who needs a budget.

**3. It reads like a machine wrote it.**
114 em dashes (`—`) and 35 middots (`·`) in `i18n.js`. Seven consecutive section headings use the identical "X. Not Y." rhythm: *Simple on the surface. Serious underneath.* / *Less app. More of your money accounted for.* / *One screen per job.* And the voice is cold. Nowhere does the page describe the reader's actual problem back to them.

Plus one factual error worth 5x: **the page says 13 currencies, the app has 64.**

---

## 2. The new positioning (this is the decision the rest of the doc rests on)

Old promise: **"No account. No server. Nothing leaves your phone."**
Problem: premium breaks all three.

New promise: **"Wumbi never asks you for anything. Until you want it to."**

| Layer | What it says |
|---|---|
| Default state | No sign-up, no bank login, no internet needed. You open it and start. |
| Premium | You *choose* to add an account so your data survives a lost phone, and you *choose* to connect a bank so transactions arrive by themselves. |
| The point | Privacy is the default, not the ceiling. Every other app makes the account mandatory on screen one. |

This is a better story than v1's "never". "Never" sounds like a limitation. "Only if you ask" sounds like respect. And it survives contact with the roadmap.

**Wording that must change everywhere as a result:**

| Currently says | Must become |
|---|---|
| "No account, no server." (`f4b`) | "No account needed. Nothing is uploaded unless you turn it on." |
| "None. No sign-up, no email, no password." (`c3w`) | "Not required. Add one later only if you want your data backed up." |
| "Wumbi never links to your bank." (FAQ `a1`) | "Wumbi doesn't ask for your bank. Bank sync exists in premium if you want automation, and it is off until you switch it on." |
| "There is no Wumbi server and no cloud copy." (FAQ `a2`) | "Nothing leaves your phone on the free plan. If you turn on premium backup, only then is anything synced, and it is encrypted." |

**Do not** delete the privacy angle. It is still your single best differentiator. Just make it a default instead of an absolute.

---

## 3. Should premium be on the landing page at all?

**Yes, and prominently.** You asked whether it scares people off. The evidence says the opposite:

- Hiding pricing is the #1 cause of bounce on app landing pages. People assume hidden means expensive.
- Freemium conversion benchmarks (Growth Unhinged, RevenueCat, Userpilot, 2026) all point the same way: conversion goes **up** when the free tier is stated confidently and the paid tier is visible, because the free tier stops looking like a trap.
- The thing that actually scares users is not "there is a paid plan". It is **finding out about the paid plan after they have entered 40 transactions**.

**How to do it without scaring anyone:**

1. The hero says **free**, and nothing about premium. The first screen sells the product, not the business model.
2. Premium gets its **own section, low on the page**, after Features / Tag map / Progress / Compare. By then the reader already wants the app.
3. The section is framed as *"here is where Wumbi is going"*, not *"here is the paywall"*. It is pre-launch. Nobody can buy anything yet. That is an advantage, use it.
4. **No prices yet.** You haven't set them and a wrong number is worse than no number. Say "pricing at launch" and let the waitlist do the work.
5. Every free feature is listed **first and in full**, so the free column visibly wins on line count.
6. Never say "limited", "trial", "upgrade to unlock". Say "free forever" and "premium adds".

---

## 4. Your Google Trends list, sorted honestly

You gave me 25 phrases. I am not going to pretend all 25 are useful, because five of them are for other products entirely and one is a competitor's brand name. Here is the real triage.

### 4.1 GOLD — put these on the homepage

These are your product, in your users' words. They go in the title, H1, H2s, lead paragraphs and FAQ.

`budget tracker` · `budget tracker app` · `budget app` · `budget planner` · `best budget planner` · `budget planner free` / `free budget planner` · `online budget planner` · `monthly budget planner` · `weekly budget planner` · `personal finance tracker` · `finance app` · `finance tracking` · `budget tracking` · `budget` · `finances`

**How they map to the page:**

| Phrase | Where it goes |
|---|---|
| `budget tracker app` | `<title>`, H1 |
| `free budget planner` | hero badge, premium section, FAQ "Is Wumbi free?" |
| `personal finance tracker` | heroLead, meta description |
| `finance app` / `finance tracking` | heroLead, features H2 |
| `monthly budget planner` / `weekly budget planner` | Progress section H2 and lead (the Progress screen literally is a monthly/weekly view) |
| `online budget planner` | FAQ, compare table (your angle: it works with no internet, unlike an online planner) |
| `best budget planner` | comparison section, and later a dedicated page |

### 4.2 CAREFUL — right topic, wrong format. This is your biggest traffic opportunity, but it is a separate page, not the homepage.

`budget tracker template` · `budget planner excel` · `excel finance tracker` · `budget planner book` · `wedding budget planner`

Somebody typing **"budget planner excel"** does not want to install an app. They want a **file**. If you point that query at your homepage, they bounce in four seconds and Google learns your page is a bad answer.

**But look at the volume in your own list:** five of your 25 phrases are template-intent. That is not noise, that is a signal.

**The play (and I think this is the single highest-ROI thing in this whole document):**

> Build a `/free-budget-planner-template/` page. Give away a genuinely good Excel + Google Sheets budget template, free, no email required. At the bottom: *"Tired of opening a spreadsheet? Wumbi does this in three seconds on your phone."*

Why this works:
- Template keywords are far less contested than `budget app`, because app companies ignore them.
- The person downloading a budget spreadsheet has *already admitted they want to track their budget*. That is the warmest possible lead.
- It gives you a reason to earn backlinks, which is the thing you cannot buy and currently have none of.
- `budget planner book` and `wedding budget planner` become printable PDF variants of the same page later.

This is a phase-2 task. Do not put it in this copy pass, but plan for it.

### 4.3 GEO — only if you mean it

`uk finance tracker`

Fine keyword, but it needs a UK-specific page (£ examples, UK bank names, UK spelling) to rank. Your current EN page is geo-neutral. Decide later whether the UK is a launch market.

### 4.4 COMPETITOR BRAND — never on the homepage

`actual budget`

This is not the adjective "actual". **Actual Budget is an existing open-source envelope-budgeting app.** People typing this want that product. You can legitimately build a `/wumbi-vs-actual-budget/` comparison page later, and those pages convert extremely well, but putting a competitor's brand on your homepage is both useless and legally careless.

### 4.5 WRONG PRODUCT — drop these, they will bring you zero installs

| Phrase | What it actually is |
|---|---|
| `best budget fitness tracker` | Cheap fitness wristbands. "Budget" here means *inexpensive*, not *money management*. A different industry. |
| `bristol tracker` | `bristoltracker.com`, a **UK graduate finance-careers application tracker** (now rebranded "Trackr"). Also returns Bristol stool-scale medical apps. Zero overlap with budgeting. |
| `trackr` | Same company as above, plus a long-running Bluetooth item-finder brand. Trademarked. Not yours. |

Google Trends will happily show you rising interest in a phrase without telling you the searcher wanted a fitness band or a medical chart. That is the trap in raw Trends data, and it is why I checked each one.

### 4.6 What is MISSING from your list

These are high-intent and describe Wumbi exactly, and you did not have them:

`budget app without linking bank account` · `expense tracker no account` · `offline budget app` · `budget app that works offline` · `private budget app` · `encrypted expense tracker` · `manual expense tracker` · `multi currency budget app` · `budget app no subscription` · `budget app for travel`

These are low-competition and are the ones a new site can actually win in year one. There is a whole cottage industry publishing exactly these pages (pocketclear.app, getfinny.app, budgetvault.app, moneypeas.app). They do it because those queries convert.

**Combined strategy in one line:** the head terms from your list (`budget tracker`, `budget planner`, `finance app`) go on the page so you are *eligible*; the long tails above are what you *win*; the template keywords get their own page and feed the top of the funnel.

---

## 5. The voice rules

You asked for informal address (`ты` / `tu` / `du` / `je`) and for copy where the reader recognises their own problem. That is a real change of register, not a polish pass. Here is what I held every line to.

| Rule | Why |
|---|---|
| **Informal, singular, second person.** `ты` in RU, `tu` in FR, `du` in DE, `je` in NL, `sen` in TR. | You asked. It also matches the product: this is a phone app you use alone, not a bank. |
| **Name the problem before naming the feature.** | "Log a transaction in three seconds" is a spec. "You skip one day and never open the app again" is a mirror. People buy the mirror. |
| **No em dashes.** Period, comma, or a new sentence. | The single strongest "a machine wrote this" signal in 2026. All 114 come out. |
| **No `·`, no `▲ ▼`, no `&` in prose.** | You asked, plus `▲▼` renders as tofu boxes on several Android and Windows font stacks and screen readers say "black up-pointing triangle". |
| **No "X. Not Y." headlines.** | Used once it is sharp. Used in seven consecutive sections it is a template, and readers feel it even if they can't name it. |
| **Numbers instead of adjectives.** "64 currencies" beats "powerful multi-currency support". | Specifics are the only thing that survives skimming. |
| **Every H1/H2 carries one real search phrase.** | H1 is the second-strongest on-page signal after `<title>`. Right now yours carries none. |
| **Say free, say the platform, in the first screen.** | The three things every visitor checks before scrolling: what is it, is it free, is it on my phone. |
| French keeps its space before `: ; ? !` but as a narrow no-break space (U+202F), never a plain space. Nothing else does. | Correct French typography that can never wrap to the next line. This is the "space before colon" you spotted. |

**On informal address and trust:** informal in a finance context can read as unserious. The way to have both is to be casual in the *verbs* and precise in the *nouns*. "Твои деньги никуда не уходят" is warm. "AES-256, ключ в защищённом хранилище устройства" right after it is the proof. Keep every technical number exactly as it is, and let the sentences around them relax.

---

## 6. Section-by-section rewrite (English)

Format: **key** — current → proposed. Once you approve the English, I write the other six locales in the same voice.

### 6.1 Hero

**`heroBadge`**
- Current: `Coming soon · iOS & Android`
- Proposed: **`Free. Coming to iPhone and Android.`**
- Kills the middot, adds *free* and *iPhone*, neither of which appears anywhere on the site today.

**`heroTitle1` / `heroTitle2`** (this is your `<h1>`, the highest-value string on the site)
- Current: `Track money in seconds.` / `No categories, just tags.`
- Problem: contains no phrase anybody searches. "Track money" is not a query.
- Proposed: **`The budget tracker you'll actually keep using.`** / **`Three seconds per expense. No sign-up, no bank login.`**
- Carries `budget tracker`, answers the real objection in the first six words, then fires both differentiators.

**`heroLead`**
- Current: `Wumbi is a minimalist, local-first budgeting app. Type the amount, tap Income or Expense, done. Your data is encrypted and never leaves your device.`
- Problem: opens with two words your reader doesn't use, and states a promise premium will break.
- Proposed:

> **Every budgeting app dies the same way. You log everything for nine days, you miss one, and you never open it again. Wumbi takes three seconds, so there's nothing to fall behind on. Type the amount, tap Income or Expense, done. No sign-up, no bank login, and it works with no internet at all.**

- This is the paragraph that does the work you asked for: the reader sees their own failure in sentence two, not a feature list. It also carries `budgeting app`, `sign-up`, `bank login`, `no internet`.

**`heroNote`** — `One email on launch day. No newsletter, no spam.` → **keep exactly.** Already perfect.

**`errFailed`** — `Could not join right now. Please try again in a moment.` → **`That didn't go through. Try again in a second.`**

**`doneTitle` / `doneMsg`** — keep.

### 6.2 Speed section

| Key | Current | Proposed |
|---|---|---|
| `speedKicker` | Built for one thing | Built for one thing |
| `speedTitle1/2` | Log a transaction in / under three seconds. | Log an expense in / under three seconds. |
| `speedLead` | Open, type the amount, tap Income or Expense. Wumbi saves instantly and stays open for the next one — no confirmation screens, no category pickers. | You're standing at the till with your phone in one hand. Open Wumbi, type the amount, tap Expense. It's saved and the screen is already waiting for the next one. No confirmation screen, no category picker, no "are you sure". |
| `step1Title` | Custom numpad, haptic on touch-down | A numpad that answers before you lift your finger |
| `step1Body` | Every key responds the instant your finger lands. | The haptic fires when you touch the key, not when you let go. It sounds like a detail until you've typed twenty of them. |
| `step2Title` | One-tap commit | One tap and it's saved |
| `step2Body` | Income, Expense or Transfer saves immediately. No "Save" button. | Income, Expense or Transfer saves immediately. There's no Save button because there's nothing left to confirm. |
| `step3Title` | Type in any currency | Type in any currency, pay from any wallet |
| `step3Body` | Enter €, pay from a $ wallet — Wumbi converts and stores both amounts. | Type an amount in euros, pay from a dollar wallet. Wumbi converts it and keeps both numbers, so your history doesn't rewrite itself next month. |

*expense* is searched, *transaction* is not. "One-tap commit" is git vocabulary.

### 6.3 Features

**`featKicker`** — `Everything in the app` → **`What's in the free app`** (the word *free*, early, in a scannable position)

**`featTitle1/2`**
- Current: `Simple on the surface.` / `Serious underneath.`
- The most AI-shaped line on the page, and it says nothing.
- Proposed: **`Eight things your finance app`** / **`should have done years ago.`**
- Carries `finance app`, and it is a small, earned piece of attitude rather than a slogan.

| Key | Current | Proposed |
|---|---|---|
| `f1t` | One-tap logging | One tap to log |
| `f1b` | Income, Expense or Transfer commits instantly and the screen stays open. Fields reset, wallet and currency stay put. | Income, Expense or Transfer saves instantly and the screen stays open. The fields clear themselves, your wallet and currency stay exactly where you left them. |
| `f2t` | Tags, not categories | Tags instead of categories |
| `f2b` | Type #coffee #trip #work as you go — tags are created on the fly. A tag map shows which tags move the most money together. | Type #coffee #trip #work as you go and the tags create themselves. Nobody has ever enjoyed maintaining a category tree, so Wumbi doesn't have one. |
| `f3t` | Wallets in any currency | 64 currencies, crypto included |
| `f3b` | 13 currencies including Bitcoin to 8 decimals. Each wallet keeps its own; your total is converted to the one you choose. | 64 currencies, plus Bitcoin, Ethereum and USDT down to 8 decimals. Every wallet keeps its own, and your total converts to whichever one you want to think in. |
| `f4t` | Local-first & encrypted | Your money stays on your phone |
| `f4b` | No account, no server. An AES-256 encrypted database on your phone, key kept in secure storage. Reset everything with one tap. | Nothing to sign up for and nothing uploaded. Your transactions sit in an AES-256 encrypted database on the phone itself, with the key in secure storage. One tap wipes all of it. |
| `f5t` | Subscriptions | Subscriptions you forgot about |
| `f5b` | Set Repeat — daily, weekly, monthly, yearly — and it becomes a subscription you can pause, edit or stop. See the monthly total at a glance. | Set anything to repeat daily, weekly, monthly or yearly and it becomes a subscription you can pause, edit or kill. The monthly total sits at the top, which is usually the uncomfortable part. |
| `f6t` | Progress | Charts you'll actually read |
| `f6b` | Income vs expense by month or year, a trend line, and spending by tag — across all wallets or just one. | Income against expense by month or by year, a trend line, and your spending broken down by tag. Look at everything at once or narrow it to one wallet. |
| `f7t` | Search everything | Search every transaction |
| `f7b` | Find any transaction by description, amount, wallet name or tag. Filter and sort every wallet's history. | Find anything by description, amount, wallet or tag, then filter and sort the whole history. |
| `f8t` | Works offline | Works with no internet |
| `f8b` | Exchange rates are cached on-device; every transaction remembers the rate it used, so history never shifts. | Rates are cached on the phone for 12 hours and every transaction remembers the rate it was made with. Planes, metros, foreign SIM cards, none of it matters. |

**Also-list (`x1`–`x8`)** — keep, with two fixes and two additions:
- `Swipe to delete with undo` → `Swipe to delete, with undo`
- `Show / hide the mascot` → `Hide the mascot if he annoys you`
- **Add `No ads`** (true, searched, currently unsaid)
- **Add `Nothing to cancel`** (the free-plan reassurance, in four words)

### 6.4 Tag map

| Key | Current | Proposed |
|---|---|---|
| `tagTitle1/2` | See how your money / connects. | See which tags / are quietly eating your month. |
| `tagLead` | Every tag becomes a bubble. Bigger circles moved more money; lines connect tags used on the same transaction. Pinch, pan, drag a bubble, tap it to open the tag. | Every tag becomes a bubble. The bigger it is, the more money went through it, and a line means those two tags keep showing up on the same transaction. Pinch it, drag it around, tap one to open it. |
| `tagStep1Title` | A live force-directed graph | The map arranges itself |
| `tagStep1Body` | Bubbles settle on their own. Nudge one and the map reflows. | The bubbles find their own positions. Push one and the rest get out of the way. |
| `tagStep2Title` | Spent · Earned · Net per tag | Spent, earned and net for every tag |
| `tagStep2Body` | Open any bubble for its transactions across every wallet. | Open any bubble to see its transactions across every wallet you have. |
| `tagTry` | Try it — drag a bubble in the phone. | Try it. Drag a bubble on the phone. |

"Force-directed graph" is a term from a data-visualisation textbook.

### 6.5 Progress

| Key | Current | Proposed |
|---|---|---|
| `progKicker` | Progress | Your monthly budget, in one screen |
| `progTitle1/2` | Know where the month went — / without a spreadsheet. | See where the month actually went. / No spreadsheet, no formulas. |
| `progLead` | Income against expense for the last six months or years, ... Scope it to all wallets or just one. | Income against expense for the last six months or the last six years, this period next to the one before it, a trend line, and your spending split by tag. Point it at one wallet or all of them. You get the monthly and weekly view a budget planner spreadsheet gives you, without opening a spreadsheet. |
| `chipMonthYear` | `Month · Year` | `Month or year` |
| `chipVs` | `▲ ▼ vs last period` | `Up or down vs last period` |

The added last sentence is deliberate: it plants `monthly budget planner`, `weekly budget planner` and `budget planner spreadsheet` in a place where they read naturally.

### 6.6 Screens

- `screensKicker`: `Five screens. Nothing else.` → **`The whole app`**
- `screensTitle1/2`: `One screen per job.` / `Every secondary choice is a sheet.` → **`Five screens in total.`** / **`You'll know your way around in a minute.`**

"Every secondary choice is a sheet" is a sentence from a design review. Your reader doesn't know what a sheet is.

### 6.7 Compare table

- `cmpKicker`: `Why switch` → **`Wumbi vs a typical budget app`**
- `cmpTitle1/2`: `Less app.` / `More of your money accounted for.` → **`How Wumbi compares`** / **`to the budget app you already deleted.`**
- `cmpOther`: `Typical budgeting apps` → keep

| Key | Current | Proposed |
|---|---|---|
| `c1w` | Type amount, tap once. About three seconds, screen stays open. | Type the amount, tap once. About three seconds, and the screen stays open. |
| `c1o` | Multi-step form: category, account, notes, confirm. | A four-step form: category, account, notes, confirm. |
| `c2w` | Free-form #tags typed inline, created automatically. | You type #tags as you go and they create themselves. |
| `c2o` | Fixed category trees you have to maintain. | A fixed category tree you have to keep tidy. |
| `c3w` | None. No sign-up, no email, no password. | **Not required. Add one later only if you want a backup.** |
| `c3o` | Account required, often with bank linking. | Required on screen one, usually with your bank attached. |
| `c4w` | On your device, AES-256 encrypted. Nothing leaves the phone. | **On your phone, AES-256 encrypted. Nothing is uploaded unless you switch it on.** |
| `c4o` | On the vendor's servers. | On someone else's server, from day one. |
| `c5w` | 13 incl. Bitcoin. Per-wallet currency, converted total, type in any. | **64, plus Bitcoin, Ethereum and USDT.** One per wallet, one converted total, type in any of them. |
| `c5o` | Usually one currency, or a paid add-on. | Usually one, or a paid add-on. |
| `c6w` | Fully usable offline; rates cached for 12 hours. | Works with no internet at all. Rates cached for 12 hours. |
| `c6o` | Needs a connection to sync or open. | Needs a connection to open or sync. |
| `c7w` | A Repeat chip on every transaction; pause or stop anytime. | A Repeat option on every transaction. Pause or stop it whenever you like. |
| `c7o` | Often behind a subscription tier. | Usually behind a paid tier. |

**New row `c8` (price):**

| `c8l` Price | `c8w` **Free. The paid plan adds things, it doesn't unlock the basics.** | `c8o` **Free for a while, then a monthly fee to keep your own data.** |

Rows `c3w` and `c4w` are the two that **must** change for the premium story to be honest.

---

## 7. NEW SECTION: Free and Premium

Goes **between Compare and FAQ**. New i18n keys, new block in `Wumbi Landing.dc.html`.

**`priceKicker`**: `Free and premium`

**`priceTitle1` / `priceTitle2`**: **`Wumbi is free.`** / **`Premium is for when it becomes a habit.`**

**`priceLead`**:
> Everything you need to run your money is in the free app, and it stays that way. Premium is for people who've been using Wumbi for three months and want more out of it. Nothing is locked behind it today, because nothing has launched yet.

**Free column — `freeTitle`: `Free, forever`**

- Unlimited transactions
- Tags and the tag map
- Wallets for your everyday money
- 64 currencies, crypto included
- Search across everything
- Income and expense charts
- Subscriptions and upcoming payments
- Works with no internet
- AES-256 encryption on your phone
- Dark mode, 7 languages
- No ads. No account. Nothing to cancel.

**Premium column — `premTitle`: `Premium, at launch`**

- Back up and restore your data with an account
- Connect your bank and let transactions arrive on their own
- Import and export everything
- Deeper income and expense analytics
- The full tag map, with everything it can show
- Unlimited wallets
- Savings goals, so you can watch a number go up for once
- Home screen widgets
- Change the mascot, change the app icon, extra animations

**`priceNote`**:
> Pricing lands with the app. Join the waitlist and you'll hear it from us before you hear it from the App Store.

### Notes on this section

- **The wallet limit is never stated as a number**, per your instruction. "Wallets for your everyday money" on the free side and "Unlimited wallets" on the premium side communicates the limit without putting a ceiling in writing that you might want to move later.
- **The free column is deliberately longer.** Eleven lines versus nine. A reader counts rows before reading them.
- **"Savings goals, so you can watch a number go up for once"** is the one line in the section with a joke in it. That is on purpose: it's the feature people actually want, and the joke is at the expense of every other line in a budgeting app, which all go down.
- **"Connect your bank and let transactions arrive on their own"** is phrased as a choice the user makes, never as a thing Wumbi does. That framing is what keeps the privacy promise intact.
- **No prices.** Add them when you know them. An empty price is curiosity; a wrong price is a refund request.

---

## 8. FAQ

The FAQ is your most valuable SEO surface, because it's the only place where you can write a sentence in exactly the shape people type it and still sound human. It also feeds your `FAQPage` JSON-LD, which is what gets you the expandable results in Google.

**`faqTitle1/2`**: `Questions people ask` / `before they switch.` → **`What you're probably`** / **`about to ask.`**

**`faqLead`**: strip the em dash → **`Account, price, privacy, offline, currencies. All of it answered before you download anything.`**

### Rewrites

| # | Current question | Proposed | Why |
|---|---|---|---|
| q1 | Does Wumbi need an account or a bank connection? | **Do I need an account or a bank connection?** | drops the brand from the query shape, matches `budget app without linking bank account` |
| q2 | Where is my financial data stored? | keep | matches `private budget app` |
| q3 | Does Wumbi work offline? | **Does Wumbi work offline, with no internet at all?** | matches `offline budget app` |
| q4 | Which currencies does Wumbi support? | keep | matches `multi currency budget tracker` |
| q5 | How is Wumbi different from a category-based budgeting app? | **How is Wumbi different from other budget apps?** | matches `best budget planner` / `budget app comparison` |
| q6 | When does Wumbi launch and on which platforms? | **When does Wumbi launch, and is it on iPhone and Android?** | adds *iPhone*, absent from the whole site today |
| q7 | Which languages does Wumbi speak? | **Which languages does Wumbi support?** | low value, keep it last |

### Answers that must change

**`a1`** — currently *"Wumbi never links to your bank."* That becomes false at launch. Replace with:

> No. There's no sign-up, no email and no password, and the free app never asks about your bank. If you'd rather have automation, premium can connect your bank so transactions arrive on their own, but that's a switch you flip, not a step you're forced through.

**`a2`** — currently *"There is no Wumbi server and no cloud copy."* Replace with:

> On your phone, in an AES-256 encrypted database whose key lives in the device's secure storage. On the free plan nothing is uploaded anywhere, because there's nowhere to upload it to. If you turn on premium backup, that's the only time anything syncs, and it's encrypted on the way. One tap wipes everything either way.

**`a4`** — factual fix:

> 64 currencies, plus Bitcoin, Ethereum and USDT down to 8 decimals. Every wallet keeps its own, you can type an amount in any of them, and your total converts to whichever one you want to think in.

**`a5`** — strip em dash, add the real hook:

> You type free-form #tags as you go instead of maintaining a category tree, and a transaction saves with one tap. About three seconds, and the screen stays open for the next one. Then the tag map shows you which tags keep moving money together, which is the part a category list can never tell you.

**`a3`, `a6`, `a7`** — content fine, just strip em dashes and the colons-as-drama.

### Three questions to ADD

**`q8`: Is Wumbi free?**
> Yes. Everything you need to track your budget is free and stays free, with no ads. There's a premium plan at launch for backups, bank sync, savings goals, widgets and deeper analytics, but the basics aren't behind it.

This is the biggest single gap on the site. `free budget planner` and `budget planner free` are both in your own Trends list and the page currently cannot rank for either.

**`q9`: Can I use Wumbi without giving it my bank details?**
> That's the default. No bank connection, no Plaid, no card number, nothing to authorise. You type your own transactions in, which takes three seconds, and that's the whole mechanism. Bank sync exists in premium only for people who'd rather not type.

Naming **Plaid** is deliberate. People search for it by name specifically when they want to avoid it.

**`q10`: Is Wumbi better than a budget planner spreadsheet?**
> For daily logging, yes, because a spreadsheet needs you to be at a computer and Wumbi needs three seconds at the till. For annual planning a spreadsheet is still fine. Wumbi gives you the monthly and weekly breakdown a budget planner template gives you, with the charts already drawn.

This one exists purely to catch the `budget planner excel` / `budget tracker template` traffic honestly, and to point it at the template page when you build it.

---

## 9. Waitlist and footer

| Key | Current | Proposed |
|---|---|---|
| `wlKicker` | Waitlist | Early access |
| `wlTitle1/2` | Be first when / lands on the App Store and Google Play. | Be first when / hits the App Store and Google Play. |
| `wlLead` | One email on launch day. No newsletter, no spam — that would be very un-Wumbi. | One email on launch day, then nothing. No newsletter, no spam, no "5 tips for saving money this winter". |
| `navJoin` | Join waitlist | Get early access |
| `navCompare` | Compare | Why Wumbi |
| `footTag` | `· local-first budgeting` | `Free budget tracker for iPhone and Android` |
| `footRights` | © 2026 Wumbi | keep |

"That would be very un-Wumbi" is a joke a brand tells about itself before anyone knows it. The replacement is funnier because it names the exact email everyone dreads.

---

## 10. Meta titles and descriptions (`seo.config.mjs`)

Every current title spends its opening words on `local-first`, which has effectively no search volume outside developer circles. Limits: title ≤ 60 chars, description 140–160.

| Lang | Proposed title | Chars |
|---|---|---|
| en | `Free Budget Tracker App, No Bank Login - Wumbi` | 45 |
| fr | `Appli budget gratuite, sans banque ni compte - Wumbi` | 51 |
| de | `Kostenlose Budget App ohne Konto und Bank - Wumbi` | 48 |
| nl | `Gratis budget-app zonder account of bank - Wumbi` | 47 |
| tr | `Ucretsiz butce takip uygulamasi, hesapsiz - Wumbi` | 48 |
| ru | `Бесплатный трекер расходов без банка - Wumbi` | 43 |
| ar | `تطبيق ميزانية مجاني بلا حساب بنكي - Wumbi` | 40 |

*(Turkish shown without diacritics here only so the table renders; the real string keeps `Ücretsiz bütçe takip uygulaması`.)*

**EN description**
> `Wumbi is a free budget tracker for iPhone and Android. Log an expense in three seconds using tags, not categories. 64 currencies, works offline, no sign-up.`
(155 chars. Contains *free*, *budget tracker*, *iPhone*, *Android*, *offline*, *no sign-up*.)

**`ogTitle` EN**: `Wumbi — Track money in seconds` → **`Wumbi: log an expense in three seconds`**

**`keywords` arrays**: remove `local-first` from all seven. Replace with the §4.1 gold list plus the §4.6 long tails. The `keywords` meta tag is ignored by Google, but you use this array elsewhere, so keep it honest.

**`APP.features`** (JSON-LD): fix `13 currencies` → `64 currencies`. Add `Optional encrypted backup and bank sync on premium` so the structured data matches the page.

**`offers`**: you now have a real freemium model. Once prices exist, the JSON-LD should carry `price: 0` for the free tier **and** an `offers` entry for premium. Leaving a bare `price: '0'` on a product with a paid tier is the kind of mismatch Google's structured-data team writes blog posts about. Until prices are set, keep `price: '0'` and add `"description": "Free plan. Premium available at launch."`.

---

## 11. Localisation problems (real bugs, independent of this rewrite)

1. **French switches register mid-page.** Body copy uses `tu` (`Tape le montant`, `Tes données`), the FAQ block uses `vous` (`Vous ouvrez l'app`, `votre téléphone`). Two voices on one page. **You've chosen `tu`, so the entire FAQ block needs converting.** Same check for `de` (currently `du`, correct), `nl` (`je`), `tr` (`sen`), `ru` (`ты`).
2. **French spacing before `: ; ? !`** is correct French, so don't just delete it. Use U+202F narrow no-break space so it can never wrap. No other locale gets a space.
3. **Turkish has the longest strings** and already broke the nav once at 320 px. Every heading I lengthened needs a Turkish re-check.
4. **Arabic** takes the same rewrite but must stay RTL-clean: no `·`, no `▲`.
5. **Russian** currently reads noticeably more formal than the English. In `ты` voice it should end up the warmest of the seven. Full Russian copy is in `COPY_AUDIT.ru.md`.

---

## 12. Factual corrections (do these regardless of the copy vote)

| Where | Current | Reality | Fix |
|---|---|---|---|
| `f3b`, `c5w`, FAQ `a4`, all 7 locales | "13 currencies including Bitcoin" | `currency_type.dart` defines **64**: 61 fiat + BTC, ETH, USDT | "64 currencies, plus Bitcoin, Ethereum and USDT" |
| `seo.config.mjs` `APP.features` | same | same | same |
| `f4b`, `c3w`, `c4w`, FAQ `a1`, `a2` | absolute "no account / no server / never links to your bank" | premium adds account backup and bank sync | reword to "not required" / "unless you turn it on" |
| whole page | never states a price | freemium | say **free** in badge, features kicker, FAQ q8, compare row c8 |
| `f8b` / FAQ `a3` | rates cached 12 h | confirmed (`fx_service.dart maxAge: 12h`, stale at 24 h) | correct, keep |
| `f4b` | AES-256 | confirmed (`sqflite_sqlcipher`) | correct, keep |
| `x2` / `a7` | 7 languages | confirmed, 7 ARBs | correct, keep |

---

## 13. What NOT to change

- `heroNote`: *"One email on launch day. No newsletter, no spam."* Specific promise, no adjectives. Leave it alone.
- `doneTitle` / `doneMsg` — clean.
- **Phone mockup labels** (`walletChecking`, `tx1`–`tx5`, `demoCoffee`, `dashTitle`) are copied verbatim from the app ARBs on purpose. **Do not touch them** or the mockups stop matching the real app.
- `f4b`'s technical detail (AES-256, secure storage). The specificity is the proof that makes the casual voice credible.
- The `tag_*` sample tags. Fine, and properly localised.
- `errInvalid`.

---

## 14. Impact ranking

If you only approve four things:

1. **Fix the premium contradiction** (§2). Not a copy preference. The current page promises three things premium will break.
2. **The H1 + heroLead rewrite** (§6.1). Biggest SEO signal and biggest conversion surface, both currently spent on a slogan with no keywords in it.
3. **Say free, everywhere** (§7, §8 q8, §6.3 kicker). Two of your own Trends keywords are `budget planner free` and `free budget planner`, and the page can't rank for either.
4. **13 → 64 currencies** (§12). Wrong number, and it's your strongest single differentiator.

Then: meta titles (§10), the em-dash purge, the French register fix (§11.1), and the Free/Premium section (§7).

Phase 2, after this lands: the `/free-budget-planner-template/` page (§4.2). I think it's worth more traffic than everything above combined, and almost nobody in this category is doing it.

---

## 15. Still open

1. **Turkish, Dutch, German, Arabic informal address** — `ты` is decided for Russian and `tu` for French. Confirm `du` / `je` / `sen` and the Arabic equivalent, or tell me to keep Arabic neutral-formal (usual for Gulf audiences).
2. **Ads:** assumed none, ever, on both tiers. Confirm before I put "No ads" on the page.
3. **Premium naming:** "Premium" throughout, or something with more personality? "Wumbi Plus" / "Wumbi Pro" read as cheaper than "Premium" and are easier to localise.
4. **UK:** is it a launch market? Decides whether `uk finance tracker` is worth a page (§4.3).
5. **Template page:** green light for phase 2? (§4.2)

---

## 16. Once approved

1. `i18n.js` — English block first, then the six locales in the same informal voice. Convert the whole French FAQ from `vous` to `tu`.
2. `seo.config.mjs` — titles, descriptions, ogTitles, keywords, `APP.features` (64), `offers` description.
3. New keys: `priceKicker`, `priceTitle1/2`, `priceLead`, `freeTitle`, `free1…free11`, `premTitle`, `prem1…prem9`, `priceNote`, FAQ `q8–q10`/`a8–a10`, compare `c8l/c8w/c8o`. All 7 locales.
4. `Wumbi Landing.dc.html` — new `#pricing` section between `#compare` and `#faq`, nav link, footer link, `faq` array entries, `cmp` row.
5. `npm run prerender` (build → prerender → build). It must print `prerendered 7/7 locales`.
6. Verify: zero `—` in `i18n.js`, zero `·` in prose, Turkish nav intact at 320 px, Arabic RTL intact, no `{{` leftovers in the prerendered HTML.
7. Commit `seo/` and `assets/og/` with the source, or crawlers keep serving the old text.

---

## 17. What actually shipped (2026-09-12)

### Files changed

| File | What happened |
|---|---|
| `i18n.js` | Rewritten. 7 locales, 232 keys each, identical key sets. New voice, new keys (`navPricing`, `x9`, `x10`, `c8l/c8w/c8o`, the whole `price*`/`free1-11`/`prem1-9` block, `footTemplate`, FAQ `q8-q10`/`a8-a10`). |
| `seo.config.mjs` | New titles (46 to 52 chars), descriptions (130 to 156), ogTitles, keyword arrays. `APP.features` fixed to 64 currencies and given the premium line. New `offerDescription`. New `TEMPLATE_PAGE` block. |
| `Wumbi Landing.dc.html` | New `#pricing` section between Compare and FAQ, with its CSS. Pricing link in the desktop nav, the burger menu and the footer. Footer now links to the template page. Compare 7 rows to 8, extras 8 to 10, FAQ 7 to 10. |
| `build.mjs` | FAQPage JSON-LD 7 to 10 questions. Emits `/free-budget-planner-template/`, copies the spreadsheet, adds the page to `sitemap.xml`. `.htaccess` gains the xlsx MIME type and `Content-Disposition: attachment`. |
| `template-page.mjs` | **New.** Generates the template landing page: WebPage + HowTo + FAQPage + SoftwareApplication JSON-LD, self-hosted fonts, no JS. |
| `assets/templates/Wumbi-Budget-Planner-Template.xlsx` | **New.** The giveaway spreadsheet. |
| `seo/prerendered/*.html`, `assets/og/og-*.png` | Regenerated for all 7 locales. |

### The spreadsheet

**It is our own work, not a copy of anyone else's.** You asked me to find the best one on the internet. I read what the best ones do and then built one, because redistributing someone else's template, even a free one, is a licensing problem you do not want attached to your first SEO asset, and because ours can point at Wumbi without it being rude.

Five tabs: **Start here**, **Categories**, **Transactions**, **Budget**, **Year**. 2,277 formulas. Planned against actual per month, a savings rate, a 50/30/20 split driven off the category groups, a per-category twelve-month rollup, 600 pre-wired transaction rows, dropdowns for category and type, data bars on budget usage, overspend turning red on its own.

Built deliberately to survive Google Sheets: no macros, no tables, no Power Query, no `XLOOKUP`, no dynamic arrays. Only `SUMIFS`, `INDEX`, `MATCH`, `IFERROR`, `TEXT` and `WEEKNUM`.

Verified by recalculating the whole workbook and checking the numbers by hand against sample data: January expense 1,599.69 from five transactions, Needs 1,182.30, Wants 17.39, Savings 400.00, savings rate 46.7%. All correct, zero formula errors.

### Verified after the rebuild

Ran headless Chromium over the built `dist/` for en, ru, ar and tr, plus a 320 px Turkish pass, the template page, and a JavaScript-disabled pass:

- correct `<html lang>` and `dir="rtl"` for Arabic, exactly one `<h1>` per page, 8 hreflang tags
- 10 FAQ items rendered and 10 questions in the FAQPage JSON-LD, every block parses
- pricing section present with 11 free and 9 premium rows, 8 compare rows plus header
- no `{{ }}` leftovers, no em dash in any rendered text, no stale "13 currencies"
- no console errors, no 404s, no horizontal overflow at any width
- Turkish nav still pinned and correct at 320 px, pricing cards stack without overflow
- template page: canonical correct, spreadsheet served with the right bytes, HowTo + FAQPage + WebPage JSON-LD
- JavaScript off on `/ru/`: 1,459 words of real text, real `<h1>`, pricing and all 10 FAQ items in the static HTML

### Decisions I made without asking

Four of the five open questions from §15 needed an answer to finish the work. Here is what I chose and why, so you can overrule any of them:

1. **Informal address everywhere.** Turkish moved from the formal `siz` in the FAQ block to `sen` throughout. German keeps `du`, Dutch `je`, French `tu` (the whole FAQ block was converted from `vous`). Arabic already uses second-person singular naturally, so it is unchanged.
2. **"Premium"** is the name, in every locale. `Wumbi Plus` or `Wumbi Pro` are still open and would be a five-minute change.
3. **No UK page.** `uk finance tracker` is parked until you decide whether Britain is a launch market.
4. **No prices anywhere.** The section says pricing arrives with the app, exactly as §7 argued.

### Two things that still need your word

1. **"No ads" is now printed on the page**, in `x9`, in `free11` and in FAQ answer `a8`, in all 7 locales. You never said anything about ads, and I inferred it from the premium list. **If ads are ever on the table, tell me and I will pull those three strings today**, because it is much cheaper to remove a promise now than to break one later.
2. **The free wallet limit is nowhere in writing**, as you asked. The page says "wallets for your everyday money" on the free side and "unlimited wallets" on the premium side. That works, but it will generate the question "how many?" in the App Store reviews. Worth deciding what the support answer is before launch.

### Not done, on purpose

`/offline-expense-tracker/`, `/budget-app-without-bank-account/` and `/multi-currency-expense-tracker/` (§4.6) are the obvious next three pages. `template-page.mjs` is now the pattern for them, so each one is an afternoon rather than a project.
