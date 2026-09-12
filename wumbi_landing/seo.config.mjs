// Single source of truth for everything a crawler reads.
// Consumed by build.mjs (head tags, JSON-LD, sitemap) and prerender.mjs (OG images).
// Page copy lives in i18n.js; this file holds only what never appears on screen.

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
export const APP = {
  category: 'FinanceApplication',
  subCategory: 'Personal budgeting',
  platforms: ['iOS', 'Android'],
  price: '0',
  currency: 'USD',
  features: [
    'One-tap income, expense and transfer logging',
    'Free-form #tags instead of fixed categories',
    'Force-directed tag map',
    '13 currencies including Bitcoin to 8 decimals',
    'AES-256 encrypted local database, no account',
    'Full offline use with cached exchange rates',
    'Subscriptions and upcoming transactions',
    'Income vs expense progress charts',
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
    title: 'Wumbi — Local-first budget app, tags not categories',
    ogTitle: 'Wumbi — Track money in seconds',
    description:
      'Log income and expenses in seconds with #tags instead of categories. 13 currencies, AES-256 encrypted on your phone, no account, no bank linking.',
    keywords: ['budgeting app', 'expense tracker', 'local-first', 'offline budget app', 'no account budgeting', 'tag based expense tracker', 'multi currency wallet', 'privacy budgeting app'],
    ogAlt: 'Wumbi — a local-first budgeting app for iOS and Android',
  },
  fr: {
    title: 'Wumbi — Budget local, des tags plutôt que des catégories',
    ogTitle: 'Wumbi — Suivez votre argent en quelques secondes',
    description:
      'Saisissez revenus et dépenses en quelques secondes avec des #tags au lieu de catégories. 13 devises, chiffrement AES-256 sur le téléphone, sans compte.',
    keywords: ['application budget', 'suivi des dépenses', 'budget hors ligne', 'sans compte', 'gestion budget multidevise', 'application budget privée'],
    ogAlt: 'Wumbi — application de budget local-first pour iOS et Android',
  },
  de: {
    title: 'Wumbi — Budget-App mit Tags statt Kategorien',
    ogTitle: 'Wumbi — Geld in Sekunden erfassen',
    description:
      'Einnahmen und Ausgaben in Sekunden mit #Tags statt Kategorien erfassen. 13 Währungen, AES-256 verschlüsselt auf dem Handy, ohne Konto und ohne Bankzugang.',
    keywords: ['haushaltsbuch app', 'ausgaben tracker', 'budget app offline', 'ohne konto', 'mehrwährungs budget', 'datenschutz finanz app'],
    ogAlt: 'Wumbi — local-first Budget-App für iOS und Android',
  },
  nl: {
    title: 'Wumbi — Budget-app met tags in plaats van categorieën',
    ogTitle: 'Wumbi — Houd je geld in seconden bij',
    description:
      'Inkomsten en uitgaven in seconden vastleggen met #tags in plaats van categorieën. 13 valuta, AES-256 versleuteld op je telefoon, zonder account.',
    keywords: ['budget app', 'uitgaven bijhouden', 'offline budget app', 'zonder account', 'multivaluta portemonnee', 'privacy budget app'],
    ogAlt: 'Wumbi — local-first budget-app voor iOS en Android',
  },
  tr: {
    title: 'Wumbi — Kategori değil etiket kullanan bütçe uygulaması',
    ogTitle: 'Wumbi — Parayı saniyeler içinde kaydedin',
    description:
      'Gelir ve giderleri kategoriler yerine #etiketlerle saniyeler içinde kaydedin. 13 para birimi, telefonda AES-256 şifreleme, hesap gerekmez.',
    keywords: ['bütçe uygulaması', 'harcama takibi', 'çevrimdışı bütçe', 'hesapsız bütçe', 'çoklu para birimi cüzdan', 'gizlilik finans uygulaması'],
    ogAlt: 'Wumbi — iOS ve Android için local-first bütçe uygulaması',
  },
  ru: {
    title: 'Wumbi — учёт финансов с тегами, без аккаунта',
    ogTitle: 'Wumbi — записывайте траты за секунды',
    description:
      'Записывайте доходы и расходы за секунды: #теги вместо категорий, 13 валют, шифрование AES-256 на телефоне, без аккаунта и подключения банка.',
    keywords: ['приложение для учёта расходов', 'учёт финансов', 'бюджет офлайн', 'без регистрации', 'мультивалютный кошелёк', 'приватное финансовое приложение', 'трекер расходов'],
    ogAlt: 'Wumbi — приложение для учёта финансов на iOS и Android',
  },
  ar: {
    title: 'Wumbi — تطبيق ميزانية بالوسوم بدل الفئات',
    ogTitle: 'Wumbi — سجّل أموالك في ثوانٍ',
    description:
      'سجّل الدخل والمصروفات في ثوانٍ باستخدام #الوسوم بدل الفئات. 13 عملة، تشفير AES-256 على هاتفك، بلا حساب وبلا ربط بنكي.',
    keywords: ['تطبيق ميزانية', 'تتبع المصروفات', 'ميزانية دون اتصال', 'بدون حساب', 'محفظة متعددة العملات', 'تطبيق مالي خاص'],
    ogAlt: 'Wumbi — تطبيق ميزانية محلي أولًا لنظامي iOS و Android',
  },
};

// URL for a locale: default language sits at the root, the rest in /<lang>/.
export const langPath = (lang) => (lang === SITE.defaultLang ? '/' : `/${lang}/`);
export const langUrl = (lang) => SITE.url + langPath(lang);
