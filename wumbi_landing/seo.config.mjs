// Single source of truth for everything a crawler reads.
// Consumed by build.mjs (head tags, JSON-LD, sitemap) and prerender.mjs (OG images).
// Page copy lives in i18n.js; this file holds only what never appears on screen.
//
// Keyword strategy (COPY_AUDIT.md §4): head terms (budget tracker / budget planner /
// finance app) go here so the page is ELIGIBLE; the long tails (no bank link, no
// account, offline, free, multi-currency) are what we actually win. Template-intent
// queries (budget planner excel / template) live on /free-budget-planner-template/.

export const SITE = {
  name: 'Wumbi',
  url: (process.env.SITE_URL || 'https://wumbi.app').replace(/\/+$/, ''),
  themeColor: '#3B82F6',
  bgColor: '#FAFAF8',
  email: 'support@wumbi.app',
  twitter: '', // '@wumbiapp' once the account exists → enables twitter:site
  defaultLang: 'en',
  // Search Console / Bing / Yandex verification tokens (leave empty until issued).
  verification: { google: '', bing: '', yandex: '' },
  // Playwright screenshots these into assets/og/og-<lang>.png (see prerender.mjs).
  ogWidth: 1200,
  ogHeight: 630,
};

// Structured-data facts about the product. Keep in sync with the page copy.
// Wumbi is freemium: the free tier is the product, premium adds to it.
export const APP = {
  category: 'FinanceApplication',
  subCategory: 'Personal budgeting',
  platforms: ['iOS', 'Android'],
  price: '0',
  currency: 'USD',
  offerDescription: 'Free plan with unlimited transactions. Premium available at launch.',
  features: [
    'One-tap income, expense and transfer logging in about three seconds',
    'Free-form #tags instead of fixed categories',
    'Force-directed tag map',
    '64 currencies including Bitcoin, Ethereum and USDT to 8 decimals',
    'AES-256 encrypted local database, no account required',
    'Full offline use with cached exchange rates',
    'Subscriptions and upcoming transactions',
    'Income vs expense progress charts, monthly and yearly',
    'Optional encrypted backup and bank sync on premium',
  ],
};

// og:locale needs a full BCP-47 tag; `dir` comes from i18n.js meta.
export const OG_LOCALE = {
  en: 'en_US', fr: 'fr_FR', de: 'de_DE', nl: 'nl_NL',
  tr: 'tr_TR', ru: 'ru_RU', ar: 'ar_AR',
};

// title ≤ 60 chars, description 140–160 — anything longer is truncated in SERPs.
export const LOCALES = {
  en: {
    title: 'Free Budget Tracker App, No Bank Login - Wumbi',
    ogTitle: 'Wumbi: log an expense in three seconds',
    description:
      'Wumbi is a free budget tracker for iPhone and Android. Log an expense in three seconds using tags, not categories. 64 currencies, works offline, no sign-up.',
    keywords: ['budget tracker', 'budget tracker app', 'budget app', 'budget planner', 'free budget planner', 'personal finance tracker', 'finance app', 'expense tracker', 'offline budget app', 'budget app without linking bank account', 'expense tracker no account', 'private budget app', 'multi currency budget app', 'manual expense tracker', 'budget app no subscription'],
    ogAlt: 'Wumbi, a free budget tracker app for iPhone and Android',
  },
  fr: {
    title: 'Appli budget gratuite, sans banque ni compte - Wumbi',
    ogTitle: 'Wumbi : note une dépense en trois secondes',
    description:
      'Wumbi est une appli de budget gratuite pour iPhone et Android. Note une dépense en trois secondes avec des tags, pas des catégories. 64 devises, hors ligne.',
    keywords: ['application budget', 'suivi de budget', 'gestion budget', 'planificateur de budget', 'budget gratuit', 'suivi des dépenses', 'budget hors ligne', 'application budget sans compte', 'application budget sans banque', 'budget multidevise', 'finances personnelles application'],
    ogAlt: 'Wumbi, une appli de budget gratuite pour iPhone et Android',
  },
  de: {
    title: 'Kostenlose Budget App ohne Konto und Bank - Wumbi',
    ogTitle: 'Wumbi: eine Ausgabe in drei Sekunden erfassen',
    description:
      'Wumbi ist eine kostenlose Budget-App für iPhone und Android. Ausgabe in drei Sekunden erfassen, mit Tags statt Kategorien. 64 Währungen, auch offline.',
    keywords: ['budget app', 'haushaltsbuch app', 'haushaltsbuch kostenlos', 'ausgaben tracker', 'finanz app', 'budgetplaner', 'budget app offline', 'budget app ohne konto', 'budget app ohne bankzugang', 'mehrwährungs budget', 'datenschutz finanz app'],
    ogAlt: 'Wumbi, eine kostenlose Budget-App für iPhone und Android',
  },
  nl: {
    title: 'Gratis budget-app zonder account of bank - Wumbi',
    ogTitle: 'Wumbi: leg een uitgave vast in drie seconden',
    description:
      'Wumbi is een gratis budget-app voor iPhone en Android. Leg een uitgave in drie seconden vast met tags in plaats van categorieën. 64 valuta, werkt offline.',
    keywords: ['budget app', 'budget bijhouden', 'gratis budget app', 'uitgaven bijhouden', 'huishoudboekje app', 'budgetplanner', 'offline budget app', 'budget app zonder account', 'budget app zonder bank', 'multivaluta budget', 'privacy budget app'],
    ogAlt: 'Wumbi, een gratis budget-app voor iPhone en Android',
  },
  tr: {
    title: 'Ücretsiz bütçe takip uygulaması, hesapsız - Wumbi',
    ogTitle: 'Wumbi: bir gideri üç saniyede kaydet',
    description:
      'Wumbi, iPhone ve Android için ücretsiz bütçe takip uygulaması. Kategori yerine etiketle üç saniyede gider kaydet. 64 para birimi, çevrimdışı çalışır.',
    keywords: ['bütçe uygulaması', 'bütçe takip uygulaması', 'ücretsiz bütçe uygulaması', 'harcama takibi', 'finans uygulaması', 'bütçe planlayıcı', 'çevrimdışı bütçe', 'hesapsız bütçe uygulaması', 'banka bağlantısız bütçe', 'çoklu para birimi bütçe', 'gizlilik finans uygulaması'],
    ogAlt: 'Wumbi, iPhone ve Android için ücretsiz bütçe takip uygulaması',
  },
  ru: {
    title: 'Бесплатный трекер расходов без банка - Wumbi',
    ogTitle: 'Wumbi: записывай траты за три секунды',
    description:
      'Бесплатный трекер расходов для iPhone и Android. Записывай трату за три секунды: теги вместо категорий, 64 валюты, работает офлайн, без регистрации.',
    keywords: ['трекер расходов', 'приложение для учёта расходов', 'учёт финансов', 'личные финансы', 'планировщик бюджета', 'бесплатный трекер расходов', 'приложение для бюджета', 'учёт расходов офлайн', 'учёт расходов без регистрации', 'бюджет без привязки банка', 'мультивалютный учёт', 'приложение для бюджета без рекламы'],
    ogAlt: 'Wumbi, бесплатный трекер расходов для iPhone и Android',
  },
  ar: {
    title: 'تطبيق ميزانية مجاني بلا حساب بنكي - Wumbi',
    ogTitle: 'Wumbi: سجّل مصروفًا في ثلاث ثوانٍ',
    description:
      'Wumbi تطبيق ميزانية مجاني لـ iPhone و Android. سجّل مصروفًا في ثلاث ثوانٍ بالوسوم بدل الفئات. 64 عملة، ويعمل دون اتصال وبلا تسجيل.',
    keywords: ['تطبيق ميزانية', 'تطبيق ميزانية مجاني', 'تتبع المصروفات', 'إدارة الميزانية', 'تطبيق مالي', 'مخطط ميزانية', 'ميزانية دون اتصال', 'تطبيق ميزانية بدون حساب', 'ميزانية بلا ربط بنكي', 'محفظة متعددة العملات', 'تطبيق مالي خاص'],
    ogAlt: 'Wumbi، تطبيق ميزانية مجاني لـ iPhone و Android',
  },
};

// The /free-budget-planner-template/ page: an original Excel + Google Sheets budget
// template given away to catch the template-intent cluster (budget planner excel,
// budget tracker template, excel finance tracker) that the app pages must not target.
export const TEMPLATE_PAGE = {
  path: '/free-budget-planner-template/',
  file: 'budget-planner-template',   // assets/templates/<file>.xlsx and .csv
  version: '1.0',
  title: 'Free Budget Planner Template for Excel and Google Sheets',
  description:
    'A free monthly budget planner template for Excel and Google Sheets. 12 months, auto totals, category rollups and a savings-rate dashboard. No email required.',
  keywords: ['budget planner template', 'budget planner excel', 'excel finance tracker', 'budget tracker template', 'free budget planner', 'monthly budget planner', 'weekly budget planner', 'online budget planner', 'budget spreadsheet', 'google sheets budget template'],
};

// URL for a locale: default language sits at the root, the rest in /<lang>/.
export const langPath = (lang) => (lang === SITE.defaultLang ? '/' : `/${lang}/`);
export const langUrl = (lang) => SITE.url + langPath(lang);
