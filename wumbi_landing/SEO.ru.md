# SEO лендинга Wumbi — что настроено и что делать дальше

Всё техническое уже в репозитории (`wumbi_landing/`). Этот файл — как это работает,
как это поддерживать и что осталось сделать руками (там, где нужен доступ к домену
и к Search Console).

---

## 0. Главное, что было сломано

Лендинг — это Claude Design canvas, который рендерит **React на клиенте**. До этой
правки в HTML не было ни одного слова текста: только `<x-dc>` с шаблоном и `{{ }}`.
Googlebot умеет исполнять JS, но делает это во «второй волне» (иногда через дни),
а Bing, Yandex, Facebook/Telegram/WhatsApp-превью, Slack и краулеры LLM
(GPTBot, ClaudeBot, PerplexityBot) JS **не** исполняют вообще.

Плюс на весь сайт был **один** URL: `wumbi.app/?lang=ru` — это не отдельная страница,
а параметр, и `hreflang` на такие URL Google почти всегда игнорирует, потому что
содержимое по `?lang=ru` и по `?lang=de` в исходном HTML идентично.

Обе проблемы решены пререндером и статикой по языкам.

---

## 1. Что теперь есть в сборке

### 1.1 Пререндер (`prerender.mjs`)

Playwright открывает собранную страницу, ждёт монтирования React, прокручивает её
целиком (чтобы отработали все GSAP-анимации), снимает `innerHTML` корня и кладёт в
`seo/prerendered/<lang>.html` — по файлу на язык.

`build.mjs` вставляет этот снимок в `<div id="dc-prerender">` **до** `<x-dc>`.
Снимок удаляется в момент, когда в DOM появляется `#dc-root`, — то есть **до** того,
как React отработает `componentDidMount`. Это принципиально: компонент ищет свои узлы
через `getElementById` (`#tag-graph`, `#hero-total`, `#waitlist`), и если снимок ещё
в документе, он находит его копию — ту, которую сейчас удалят. Именно так пропала
анимация карты тегов: граф рисовался в canvas, которого через миг не стало.
Итог:

- **без JS** (краулер, превью в соцсетях) видно полностью свёрстанную страницу —
  1036 слов текста на русском, `<h1>`, 8 × `<h2>`, 7 FAQ-блоков;
- **с JS** маленький скрипт удаляет снимок ровно в тот момент, когда React положил
  что-то в `#dc-root`, и дёргает `ScrollTrigger.refresh()` (без этого GSAP считает
  позиции по старой высоте документа и ничего ниже первого экрана не проявляется).

Снимки **коммитятся в репозиторий** намеренно: Hostinger при деплое выполняет только
`npm install && npm run build` и никогда не должен качать Chromium.

```bash
# после любой правки текста или вёрстки лендинга:
cd wumbi_landing
npm i -D playwright && npx playwright install chromium   # один раз
npm run prerender      # build → снимки + OG-картинки → build
git add seo assets/og && git commit -m "chore(seo): refresh prerendered snapshots"
```

> Если забыть пересобрать снимки — сайт не сломается, но краулер увидит старый текст.
> Вывод `npm run build` всегда пишет `prerendered 7/7 locales` — это контрольная строка.

### 1.2 Отдельный URL на каждый язык

```
wumbi.app/        → en  (canonical + x-default)
wumbi.app/fr/     wumbi.app/de/   wumbi.app/nl/
wumbi.app/tr/     wumbi.app/ru/   wumbi.app/ar/
```

Каждая страница — свой статический HTML со своими `<html lang dir>`, `<title>`,
`description`, `canonical`, `og:locale` и **полным взаимным набором `hreflang`**
(7 языков + `x-default`). Взаимность обязательна: если `/ru/` ссылается на `/de/`,
а `/de/` не ссылается обратно — Google выбрасывает всю группу.

Переключатель языка в шапке теперь **переходит** на `/de/`, а не подменяет строки
на месте. Это принципиально: URL, `<html lang>` и canonical обязаны совпадать с
тем текстом, который реально на экране.

Язык страницы берётся из `window.WUMBI_LANG`, который проставляет билд, — он
приоритетнее `localStorage` и `navigator.language`. Иначе человек с немецкой
системой открывал бы `/ru/` и видел немецкий текст под русским canonical — для
Google это подмена контента.

### 1.3 Структурированные данные (JSON-LD)

Один `@graph` на каждой странице, со связями через `@id`:

| Тип | Зачем |
|---|---|
| `SoftwareApplication` | Главный тип для приложения: категория `FinanceApplication`, платформы, `featureList`, `offers` c `PreOrder` |
| `Organization` | Бренд + логотип 512×512 — панель знаний |
| `WebSite` | Связывает домен с брендом |
| `WebPage` | Языковая версия страницы |
| `FAQPage` | 7 вопросов/ответов — те же, что видны на странице |

FAQ-блок реально **видимый** на странице (нативные `<details>`, без JS). Разметка
без видимого контента — нарушение правил Google и повод для ручных санкций.

Проверять: [Rich Results Test](https://search.google.com/test/rich-results) и
[Schema validator](https://validator.schema.org/).

### 1.4 FAQ-секция — это ещё и контент

До правки на лендинге был только маркетинговый текст. Поисковый трафик у
приложений идёт по вопросам: «бюджет без регистрации», «трекер расходов офлайн»,
«приложение для учёта финансов без привязки банка». Семь вопросов × 7 языков
покрывают ровно эти формулировки и дают LLM-краулерам куски, которые удобно
цитировать. Тексты — в `i18n.js`, в блоке `FAQ (SEO)` в конце файла.

### 1.5 Производительность (это тоже ранжирование)

| Что | Было | Стало |
|---|---|---|
| Маскоты | 4.6 + 2.4 + 4.5 МБ PNG | 32 + 14 + 38 КБ WebP, с `width`/`height` и `loading="lazy"` |
| | | Атрибуты `width`/`height` — это presentational hints: если в CSS задана только одна сторона, вторая берётся из атрибута и картинка плющится. `build.mjs` дописывает недостающую сторону как `auto`, поэтому атрибуты дают только соотношение сторон (ради CLS). |
| Неиспользуемые PNG | 8.5 МБ уезжали в `dist` | не копируются вообще |
| Шрифты | Google Fonts CDN, блокирует рендер | локальные woff2, `font-display:swap`, подмножества latin / latin-ext / **cyrillic** / arabic |
| GSAP | jsdelivr CDN | локально в `/vendor` |
| `dist` целиком | 26 МБ | 3.2 МБ |
| HTML страницы | — | 39 КБ в gzip |

`width`/`height` на картинках убирают CLS; `<link rel=preload>` на hero-маскот и на
нужное подмножество шрифта улучшают LCP. Кириллица раньше рисовалась системным
шрифтом — теперь это настоящий Inter.

### 1.6 Служебные файлы

- **`sitemap.xml`** — 7 URL, у каждого полный набор `xhtml:link hreflang`.
- **`robots.txt`** — всё открыто, `/vendor/` закрыт, явно разрешены GPTBot,
  OAI-SearchBot, ClaudeBot, PerplexityBot, Google-Extended, Applebot-Extended.
  Это осознанное решение: Wumbi нужно, чтобы его **цитировали** ассистенты.
- **`site.webmanifest`** + иконки 32/180/192/512 — установка на домашний экран,
  корректная иконка в выдаче.
- **`404.html`** с `noindex,follow`.
- **`.htaccess`** — HTTPS и `www → без www` **одним** редиректом (цепочка редиректов
  съедает краулинговый бюджет), слэш в конце для языковых папок, gzip/brotli,
  `Cache-Control: immutable` на ассеты и `must-revalidate` на HTML, плюс
  `X-Content-Type-Options`, `Referrer-Policy`, `HSTS`.
- **OG-картинки 1200×630** на каждый язык (`assets/og/og-<lang>.png`, ~45 КБ),
  генерируются в `prerender.mjs` скриншотом — заголовок и описание на нужном языке,
  `twitter:card = summary_large_image`.

---

## 2. Что нужно сделать руками

### 2.1 Google Search Console (в первую очередь)

1. `search.google.com/search-console` → **Add property** → **Domain** (не URL-prefix):
   подтверждение через TXT-запись в DNS Hostinger покрывает сразу все поддомены
   и оба протокола.
2. **Sitemaps** → добавить `sitemap.xml`.
3. **URL Inspection** для `/` и для `/ru/` → «Test live URL» → вкладка
   **Screenshot / HTML**: убедиться, что видно текст, а не пустой каркас.
   Это прямая проверка, что пререндер работает.
4. Через пару недель смотреть **Performance → Queries** и подгонять `title`
   и `description` в `seo.config.mjs` под реальные запросы.

### 2.2 Bing Webmaster Tools и Яндекс.Вебмастер

Bing — это ещё и ChatGPT Search, так что не пропускай. Яндекс обязателен для
русской версии. В обоих есть импорт из Search Console. Токены подтверждения
вставляются в `seo.config.mjs`:

```js
verification: { google: '…', bing: '…', yandex: '…' },
```

и автоматически попадают в `<head>` всех страниц.

### 2.3 Аналитика

Поставь что-нибудь лёгкое и cookieless — Plausible или Umami. Google Analytics для
приложения, которое продаёт приватность, — плохая история и на лендинге, и в тексте
политики. Скрипт добавлять в `head()` внутри `build.mjs`, чтобы он попал во все семь
страниц разом.

### 2.4 Страницы, которых не хватает

Для App Store и Google Play всё равно понадобятся, и они же дают ссылочный вес:

- `/privacy/` — политика конфиденциальности (обязательна для публикации в сторах);
- `/terms/` — условия использования;
- `/press/` — логотипы, скриншоты, короткое описание: это то, что копируют
  каталоги приложений и блогеры, и оттуда приходят первые внешние ссылки.

### 2.5 Внешние сигналы

Домен новый, у него нет авторитета. Первые ссылки, которые реально работают для
такого продукта: Product Hunt, Hacker News (Show HN), r/privacy, r/androidapps,
AlternativeTo, Indie Hackers, каталоги privacy-first софта. Там же указывай
`support@wumbi.app` и ссылку на нужную языковую версию.

### 2.6 После запуска в сторах

Добавить в `seo.config.mjs` реальные ссылки на App Store и Google Play и прописать
их в JSON-LD (`SoftwareApplication.downloadUrl` + `sameAs`), а `offers.availability`
поменять с `PreOrder` на `InStock`.

---

## 3. Рабочий цикл

```bash
cd wumbi_landing

npm run build       # dist/ — то, что уезжает на Hostinger
npm run preview     # http://localhost:4173
npm run prerender   # пересобрать снимки и OG (нужен Chromium)
```

Правишь текст → `i18n.js`.
Правишь title / description / ключевые слова → `seo.config.mjs`.
Правишь вёрстку → `Wumbi Landing.dc.html`.
**После любой из трёх правок** — `npm run prerender`, иначе краулер увидит старое.

Деплой на Hostinger не меняется: корневой `package.json` делегирует в
`wumbi_landing`, выходная папка — `wumbi_landing/dist`.

**Важно про `sharp`.** На Hostinger Node 18, а `sharp` требует ≥ 20.9 — сборка падала
с `Could not load the "sharp" module`. Поэтому production-сборка вообще не трогает
нативные модули: все производные картинки (WebP-маскоты, иконки 32/180/192/512)
лежат в **`assets/derived/`** и коммитятся вместе с `manifest.json`, где записаны
их размеры. `build.mjs` подгружает `sharp` лениво и только если в `assets/derived/`
чего-то не хватает — то есть локально, сразу после замены исходной картинки:

```bash
npm run images     # npm i --no-save sharp && node build.mjs
git add assets/derived
```

В `dependencies` остались только чистые JS-пакеты: react, react-dom, gsap и три
@fontsource. Ни `sharp`, ни `playwright` там нет — это локальные инструменты.

---

## 4. Чек-лист перед публикацией

- [ ] `npm run build` пишет `prerendered 7/7 locales`
- [ ] `curl -s https://wumbi.app/ru/ | grep -c "Учёт денег"` → не 0
- [ ] Rich Results Test зелёный для `/` и `/ru/`
- [ ] Превью ссылки в Telegram / WhatsApp показывает OG-картинку 1200×630
- [ ] `https://wumbi.app/sitemap.xml` открывается, в нём 7 URL
- [ ] `https://www.wumbi.app` → один 301 на `https://wumbi.app` (без цепочки)
- [ ] PageSpeed Insights: LCP < 2.5 с на мобильном
- [ ] Маскоты не растянуты, карта тегов рисуется, графики Progress анимируются
- [ ] Sitemap отправлен в Search Console, Bing и Яндекс
