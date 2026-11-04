# Wumbi — Local Notifications

Status: implemented (2026-10-26). Scope: **A — money in motion** and **C — habits**, plus the opt-in morning budget. Replaces decision D10 ("toggle is a stub").

---

## 1. How it works

```
App → background / DB write / language · currency · switches change
        │
        ▼
NotificationSnapshotSource ── reads DB through existing repositories
        │                     (rules, upcoming rows, wallets, debts, budgets, record times, this week)
        ▼
NotificationPlanner (pure)  ── what to say on which day (14-day horizon)
        ▼
NotificationPacer (pure)    ── ≤ 1 per slot, ≤ 2 per day, never in the past, "+N more inside"
        ▼
NotificationCopy            ── words in the app language (arb, hamster voice)
        ▼
NotificationGateway         ── flutter_local_notifications: cancel pending + zonedSchedule (one-shot)
```

**Why no background tasks:** Wumbi is local-first. Nothing changes in the database until the app is opened again (and opening re-plans everything). So texts computed when the app goes to the background are still true when delivered. The only things that "happen" on their own — recurring rules and upcoming rows — are projected ahead.

**Re-planning triggers** (`notificationSchedulerProvider`):

| Trigger | Delay |
|---|---|
| App → `paused` | immediate |
| `dbRevisionProvider` bump (any write) | 3 s debounce |
| Language / base currency / master switch / category switch changed | 300 ms |
| Splash `startUp` | 1 s |

Changing the language re-schedules every pending notification in the new language.

### Delivery rules

- Only two moments a day: **morning 09:00** and **evening** (learned: median time of the user's evening entries + 30 min, rounded to 15 min, kept within 19:00–21:30; 20:00 until there are 5 such entries).
- **One notification per slot** → max 2 per day. When several land in a slot, the highest priority wins; the other *money* items add a line "+N more things inside". Habit nudges are never counted as extras.
- A morning that is already gone is dropped, except **overdraft** and **debt due today**, which move to that evening.
- Horizon 14 days, ≤ 40 pending (iOS limit is 64).
- Absolute instants (local → UTC): no time-zone database needed, DST handled by Dart's local `DateTime`.
- Re-planning cancels **pending** notifications only; delivered ones stay in the notification centre.

### Hamster faces

Each message picks its own `WumbiMood`. All 34 moods ship as 256 px PNGs in `assets/mascot/notification/<mood>.png` (rendered from the same SVGs as the in-app mascot).
- Android: `largeIcon` (one shared file per mood) + monochrome status-bar icon `ic_stat_wumbi` (hamster silhouette).
- iOS: notification attachment (a fresh copy per request, iOS moves the file into its store).

### Tap

Payload = `MascotAction` (`openDebt|<id>`, `addTransaction`, …). The tap opens the same page as the in-app bubble's "View ›" — `mascotActionRoute()` was extracted from `runMascotAction` and is shared by both. Cold start: the page opens on top of the dashboard.

---

## 2. Notification types

Placeholders in `{}`; the boss / «хозяин» voice matches the in-app hamster. All 7 languages are in `lib/src/core/locale/arbs/app_*.arb` (keys `notif_*`).

### A — Payments (`Payments` switch)

| Kind | When | Face | Tap | EN | RU |
|---|---|---|---|---|---|
| **overdraftRisk** | A planned payment takes a wallet below 0 → 2 days before (or ASAP; evening fallback) | nervous | Wallet | **“{wallet}” could go negative**<br>On {date}, {name} takes {amount} and leaves {balance}. Top it up before then, boss? | **«{wallet}» может уйти в минус**<br>Списание {date}: {name}, {amount}. После него останется {balance}. Пополним заранее, хозяин? |
| **chargeTomorrow** | Recurring expense (not daily) — day before, morning | calendar | Subscriptions | **{name} charges tomorrow**<br>(a) {amount} goes out tomorrow. Just a heads-up so it doesn’t catch you off guard, boss<br>(b) Tomorrow it takes {amount} from “{wallet}”. Enough seeds in there? | **Завтра списание: {name}**<br>(a) Завтра уйдёт {amount}. Предупреждаю заранее, чтобы не стало сюрпризом, хозяин<br>(b) Завтра с «{wallet}» уйдёт {amount}. Семечек там хватит? |
| **incomeToday** | Recurring income — the day, morning | cheeksStuffed | Wallet | **Payday: {name}** / **Payday!**<br>{amount} should land today. Did it all come in, boss? | **Сегодня приход: {name}** / **День зарплаты!**<br>Сегодня должно прийти {amount}. Всё пришло, хозяин? |
| **plannedToday** | One-off upcoming row — the day, morning | handing (expense) / catching (income) | Wallet | **Today: {name}**<br>{amount} is planned for today. Tap to make sure it all went as planned | **Сегодня: {name}**<br>На сегодня запланировано {amount}. Загляни, всё ли прошло как надо |

### A — Debts (`Debts` switch)

| Kind | When | Face (owed to me / I owe) | EN (owed to me · I owe) | RU |
|---|---|---|---|---|
| **debtDueSoon** | 3 days before due | kindly / calendar | **{name} owes you {amount}** — Due in {days} days. A friendly reminder won’t hurt<br>**Paying back {name} soon** — {amount} is due in {days} days. Is the money set aside, boss? | **Скоро вернут долг: {name}** — Срок через {days} дня. Мягко напомнить — не лишнее<br>**Скоро отдавать долг: {name}** — {amount} нужно вернуть через {days} дня. Деньги отложены, хозяин? |
| **debtDueToday** | Due day (evening fallback) | pouchOpen / alert | **{name} pays you back today** — {amount} is due today. Got it? Mark it so I can stop worrying<br>**Today you pay back {name}** — {amount} is due today. Already done? Mark it and you’re all square | **Сегодня возвращают долг: {name}** — Сегодня тебе должны вернуть {amount}. Получил? Отметь, чтобы я не волновался<br>**Сегодня отдаёшь долг: {name}** — Сегодня нужно вернуть {amount}. Уже отдал? Отметь — и вы в расчёте |
| **debtOverdue** | +1, +3, +7, +14, +30 days late, then silence | impatient / nervous | **{name} is {days} days late** — {amount} still isn’t back. Maybe time for a gentle nudge?<br>**Your debt to {name} is overdue** — {days} days past due, {amount} left. Let’s settle it before it gets awkward | **Долг так и не вернули: {name}** — {amount} всё ещё не вернулись. Может, пора мягко напомнить?<br>**Долг просрочен: {name}** — {days} дней после срока, осталось {amount}. Давай закроем, пока не стало неловко |
| **debtForgotten** | Lent without due date: +30 and +60 days | thinking | **Remember {name}?** — You lent {amount} {days} days ago and it’s still not back. Worth asking? | **Не забыл про долг? {name}** — Ты дал {amount} в долг {days} дней назад, и их всё ещё не вернули. Может, спросить? |

All debt notifications open the debt. Owing money outranks being owed (+5 priority).

### C — Habits (`Evening nudges` switch)

Planned when the app leaves the screen; logging means opening the app, which re-plans — so "nothing logged that day" is guaranteed for every future day. Sequence after the last visit: **today** (only if nothing logged) → **tomorrow** → *(quiet day)* → **+3** → **+7** → silence.

| Kind | When | Face | EN | RU |
|---|---|---|---|---|
| **logReminder** v1 | Evening, nothing logged | counting | **How was today?** — Ten seconds to jot down what you spent — I’ll do the counting | **Как прошёл день?** — Десять секунд, чтобы записать траты. Считать буду я |
| **logReminder** v2 | 〃 | impatient | **Boss, I’m waiting!** — Today’s seeds aren’t counted yet. Coffee, groceries, a taxi — let’s add them? | **Хозяин, я жду!** — Сегодняшние семечки ещё не посчитаны. Кофе, продукты, такси — добавим? |
| **logReminder** v3 | 〃 | searching | **Spent anything today?** — Even small stuff adds up. Log it now while you still remember | **Тратил что-нибудь сегодня?** — Мелочи тоже складываются. Запиши сейчас, пока помнишь |
| **logReminder** v4 | 〃 | sigh | **Evening count?** — Nothing logged today yet. Let’s fix that before bed | **Вечерний подсчёт?** — Сегодня ещё ничего не записано. Давай исправим до сна |
| **streakReminder** | Instead of logReminder when the streak is ≥ 3 days | proud (victory from 14) | **{days} days in a row!** — Don’t break the streak, boss — one entry today is enough | **{days} дней подряд!** — Не прерывай серию, хозяин — сегодня хватит одной записи |
| **winBack** (missYou) | 3 days without opening | sad | **I miss you, boss** — Three days without a single entry. Let’s catch up — it only takes a minute | **Скучаю, хозяин** — Три дня ни одной записи. Давай наверстаем — это минутка |
| **winBack** (asleep) | 7 days — the last one | sleep | **Wumbi dozed off…** — A whole week of silence. Wake me up and let’s get your numbers back in order | **Wumbi задремал…** — Целая неделя тишины. Разбуди меня — наведём порядок в цифрах |

The log-reminder wording rotates per day (stable FNV seed: re-planning the same day never reshuffles it). All open "Add transaction".

### C — Weekly recap (`Weekly recap` switch)

Sunday evening, current week (Mon–Sun, base currency, planned expenses of the remaining days included). Skipped when nothing was spent. Opens Progress.

| Trend | Face | EN | RU |
|---|---|---|---|
| ≥ 5 % less | proud | **Your week: {amount}** — That’s {percent}% less than last week. Proud of you, boss! | **Твоя неделя: {amount}** — Это на {percent}% меньше, чем на прошлой. Горжусь тобой, хозяин! |
| ≥ 5 % more | thinking | … — That’s {percent}% more than last week. Want to see where it went? | … — Это на {percent}% больше, чем на прошлой. Посмотрим, куда ушло? |
| about the same | counting | … — Most of it went to “{tag}”. Tap for the full picture / Tap to see where it all went, boss | … — Больше всего ушло на «{tag}». Загляни за подробностями / Загляни — посмотрим, куда всё ушло, хозяин |

### Morning budget (`Morning budget` switch, **off by default**)

Today + tomorrow morning, one running budget per day (rotating). `perDay = free ÷ days left`.

| Case | Face | EN | RU |
|---|---|---|---|
| Money left | kindly | **Today’s “{name}” budget** — You can spend {amount} today and stay on track. Have a good one, boss | **Бюджет «{name}» на сегодня** — Сегодня можно потратить {amount} и остаться в плане. Хорошего дня, хозяин |
| Empty | stop | **“{name}” is empty** — Nothing left for this period. Let’s give it a rest today | **В «{name}» пусто** — На этот период ничего не осталось. Давай сегодня без трат отсюда |

### Digest line

`+1 more thing inside` / `+{count} more things inside` — RU: `+ ещё {count} дело/дела/дел в приложении`.

### Priorities (slot winner)

overdraftRisk 100 · debtOverdue 85 (+5 I owe) · debtDueToday 80 (+5 I owe) · chargeTomorrow 70 · debtDueSoon 65 · incomeToday 60 · plannedToday 55 · debtForgotten 50 · safeToSpend 40 · weeklyRecap 30 · streakReminder 27 · logReminder 25 · winBack 20.

---

## 3. Settings & permission

- **Settings → Notifications** (`/settings/notifications`, `NotificationSettingsPage`): live preview card (tap = next sample, shows every face), master switch, 5 category switches (dimmed while the master is off), "blocked in system settings" hint with **Open settings**.
- **Permission** goes through `permission_handler` (`NotificationPermission`, same approach as the Nour app) → `granted` / `askable` / `blocked`. `NotificationEnableFlow.run(context, ref)` is the single entry point (Settings switch, hamster ask):
  - granted → master on;
  - askable → system dialog → yes: on · no: dialog "Notifications are off" with **Open settings** / "Not now";
  - blocked (iOS after one "Don't allow", Android after two) → the app's page in the system settings opens directly.
  - Back from the system settings (`App` resumed → `NotificationsController.onForeground`): if allowed there, notifications turn on by themselves + toast "Notifications are on — I’ll keep an eye on things, boss".
- **Ask once** (`NotificationAskOnce` on the dashboard): after ≥ 3 entries, if notifications are off and the user was never asked → hamster sheet (`NotificationPermissionSheet`, kindly face + live preview) → "Sure" → system dialog. Asked once ever (`askedAt`).
- Storage: master = `settings.notifications_enabled` (existing); categories = `settings.notification_prefs` (JSON, new — **DB v7**, migration `_v6ToV7`, NULL = defaults).

---

## 4. Code map

```
lib/src/features/notification/
  domain/
    notification_kind.dart        NotificationKind (category, slot, priority), NotificationCategory, NotificationSlot
    notification_message.dart     sealed NotificationMessage + 13 types: mood, tap action, key, priority
    notification_snapshot.dart    planner input (wallets, planned moves, debts, budgets, record times, week)
    notification_planner.dart     pure planner + evening-time learning + helpers
    notification_pacer.dart       pure: slots, caps, extras, ids → ScheduledNotification
    notification_prefs.dart       per-category switches (JSON)
    notification_payload.dart     MascotAction ⇄ payload string
  data/
    notification_snapshot_source.dart  DB → snapshot (existing repositories, fails soft)
    notification_gateway.dart          the only flutter_local_notifications user
    notification_art.dart              mood PNG asset → file (Android shared / iOS per request)
    notification_permission.dart       permission_handler: status / request / openAppSettings
  ui/
    notification_copy.dart        message → title/body (l10n)
    notification_scheduler.dart   snapshot → plan → words → OS (debounced, serialized)
    notification_providers.dart   providers + NotificationsController (start, taps, switches)
    notification_enable_flow.dart permission UX: ask → refused dialog → system settings
    notification_samples.dart     sample messages for previews
    notification_settings_page.dart
    widgets/ notification_preview_card · notification_sample_preview · notification_permission_sheet · notification_ask_once
```

Touched: `mascot_actions.dart` (shared `mascotActionRoute`), settings model/datasource/repo/notifier (+prefs, startup step 5), `settings_page.dart` (tile → page), `app.dart` (paused → re-plan), `dashboard_page.dart` (ask once), routing (+route), SQLite v7, `TransactionRepository.upcoming()`, `pubspec.yaml`, Android manifest + desugaring + `ic_stat_wumbi` + `res/raw/keep.xml` (keeps the icon from R8 shrinking; plugin needs minSdk ≥ 24), iOS `AppDelegate`.

Tests: `test/features/notification/notification_planner_test.dart` (planner, pacer, payload, prefs), `notification_copy_test.dart` (every message × 7 languages), `test/core/migration_v7_test.dart`.

---

## 5. Run it

```bash
cd wumbi_app
flutter pub get                      # adds flutter_local_notifications 22.3.3, timezone 0.11, permission_handler 12; regenerates l10n
flutter gen-l10n                     # if your IDE didn't
dart run build_runner build -d       # optional: regenerates app_router.gr.dart (route was hand-added)
cd ios && pod install && cd ..
flutter analyze && flutter test
```

Quick manual test: enable notifications, create a debt due tomorrow / a monthly rule tomorrow, background the app, then move the device clock to 08:59 of the target day.

## 6. Not in this version

- Notification action buttons ("Mark settled", "Snooze") — needs a DB write from the background isolate (SQLCipher key from secure storage).
- "Hide amounts on lock screen" switch.
- B-plan budget alerts by push (threshold crossings are already shown in-app as toasts).
