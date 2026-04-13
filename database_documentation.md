# fiin — документация модели локальной базы данных

Этот документ описывает **целевую модель** данных для приложения fiin: таблицы, поля, связи, бизнес-логику и примеры. Модель рассчитана на **локальное хранение сейчас** и **синхронизацию между устройствами** в будущем, без обязательного бэкенда на первом этапе.

---

## 1. Цели и принципы

| Принцип | Зачем | Пример |
|--------|--------|--------|
| **UUID первичные ключи** | На разных устройствах можно создавать записи без коллизий id; экспорт/импорт не ломает связи. | Телефон создал кошелёк `a1b2…` до появления сети — сервер или второй девайс просто принимает этот id. |
| **Soft delete (`deleted_at`)** | Удаление не стирает историю; можно восстановить; синхронизация передаёт «удалено» как событие, а не пропажу строки. | Пользователь удалил транзакцию → `deleted_at = 1730000000`; фильтр списка: `WHERE deleted_at IS NULL`. |
| **`created_at` / `updated_at`** | Аудит, сортировка, **инкрементальный экспорт** («всё изменённое после T»). | Бэкап: `SELECT * FROM transactions WHERE updated_at > ?`. |
| **`sync_status` на сущностях** | Быстрый фильтр «что ещё не уехало на сервер / в конфликте». | После офлайн-правки: `sync_status = 'pending'`. |
| **Суммы в целых минорных единицах** | Избегаем ошибок округления `REAL`/`FLOAT` в деньгах. | $12.34 хранится как `1234` при масштабе USD (центы). |
| **Денормализация валюты на транзакции** | Если валюту кошелька когда-нибудь сменят, старые проводки останутся в «исторической» валюте. | Кошелёк был EUR, потом сменили на USD — старые строки в `transactions.currency` всё ещё `EUR`. |

**SQLite:** при использовании внешних ключей включайте `PRAGMA foreign_keys = ON;`.

### 1.1 Порядок создания таблиц (важно для внешних ключей)

Из-за ссылки `transactions.recurring_rule_id → recurring_rules.id` таблицу **`recurring_rules` нужно создать раньше, чем `transactions`**. Рекомендуемый порядок миграции:

1. `wallets`
2. `tags` (без FK на другие бизнес-таблицы)
3. `recurring_rules` (зависит от `wallets`)
4. `transactions` (зависит от `wallets`, `recurring_rules`; самоссылка `parent_transaction_id` допустима при создании таблицы)
5. `transaction_tags`
6. `recurring_rule_tags`
7. `sync_log` (без FK на бизнес-таблицы)

В тексте ниже таблицы описаны в логическом порядке «сущности приложения»; при написании SQL-миграций ориентируйтесь на список выше.

---

## 2. Хранение денег и валют

### 2.1 Поля суммы

Во всех таблицах, где есть деньги, используются **целые числа** в **минорных единицах** (например, центы для USD/EUR, копейки для RUB):

- `amount_minor` — основная величина операции (для дохода/расхода — одна сумма; для перевода см. ниже).
- Для перевода между разными валютами: `from_amount_minor`, `to_amount_minor` плюс осмысленный `exchange_rate` (как вы договоритесь в приложении — например «сколько единиц `to` на одну единицу `from`»).

**Масштаб по валюте** задаётся в коде (справочник ISO → число знаков после запятой: USD 2, JPY 0, BTC 8). В БД хранится только `currency` (код ISO 4217 для фиата; для крипто — договорённый код, например `BTC`) и целое `*_minor`.

**Пример отображения:** `amount_minor = 123456`, валюта USD (2 знака) → пользователю показываем `1234.56`.

### 2.2 Курс для перевода

**Пример:** со счёта в EUR на счёт в USD списали **100 EUR**, зачислили **108 USD**. В одной строке `transactions` типа `transfer`:

- `from_wallet_id` → кошелёк EUR, `from_amount_minor = 10000` (100.00 EUR),
- `to_wallet_id` → кошелёк USD, `to_amount_minor = 10800` (108.00 USD),
- `exchange_rate` можно хранить как рациональное приближение в приложении (например `1.08` в REAL **только для отображения/справки**) или как пару целых в отдельном поле — главное, чтобы **итог денег** считался из `*_minor`, а не из float.

---

## 3. Таблица `wallets` (кошельки)

### 3.1 Назначение

Счёт/кошелёк пользователя: имя, валюта, отображение, флаги «основной» и «не в общем балансе», **текущий баланс** (денормализация для быстрого UI).

### 3.2 Схема (целевая)

```sql
CREATE TABLE wallets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    currency TEXT NOT NULL,

    -- Баланс в минорных единицах валюты `currency` (см. раздел 2)
    initial_balance_minor INTEGER NOT NULL DEFAULT 0,
    current_balance_minor INTEGER NOT NULL DEFAULT 0,

    color TEXT,
    icon TEXT,

    is_primary INTEGER NOT NULL DEFAULT 0,
    is_excluded_from_total INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,

    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,
    sync_status TEXT NOT NULL DEFAULT 'synced'
);

CREATE INDEX idx_wallets_deleted ON wallets(deleted_at);
CREATE INDEX idx_wallets_updated ON wallets(updated_at);
```

Допустимые значения `sync_status`: например `synced`, `pending`, `conflict`.

### 3.3 Логика

1. **Один «основной» кошелёк:** в приложении при установке `is_primary = 1` для кошелька A снимайте флаг с остальных (транзакция БД: обновить все, затем выставить A).
2. **`current_balance_minor`:** обновляется **только вместе** с вставкой/изменением/soft-delete транзакций в одной транзакции SQLite (`BEGIN…COMMIT`), чтобы не было расхождения с суммой проводок. Альтернатива без хранения баланса — всегда считать `SUM` по транзакциям; тогда поле не нужно, но список кошельков на главном экране будет дороже по запросам.
3. **`is_excluded_from_total`:** кошелёк виден, но не входит в «общий баланс» на дашборде (например чисто учётный или технический).

### 3.4 Пример данных

Пользователь создал «Накопления» в USD, стартовый баланс при создании **$1 234.56**:

| id | name | currency | initial_balance_minor | current_balance_minor | color | is_primary | deleted_at |
|----|------|----------|------------------------|------------------------|-------|------------|------------|
| `w-sav-…` | Savings Vault | USD | 123456 | 123456 | #2E7D32 | 1 | NULL |

---

## 4. Таблица `transactions` (транзакции)

### 4.1 Назначение

Единая таблица для **дохода**, **расхода** и **перевода**. Тип задаётся полем `type` и определяет, какие поля обязательны (инварианты ниже).

### 4.2 Схема (целевая)

```sql
CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,

    -- Доход/расход: одна сумма в валюте операции (обычно = валюта кошелька)
    amount_minor INTEGER,
    currency TEXT NOT NULL,

    wallet_id TEXT,

    -- Перевод
    from_wallet_id TEXT,
    to_wallet_id TEXT,
    from_amount_minor INTEGER,
    to_amount_minor INTEGER,
    exchange_rate REAL,

    description TEXT,
    notes TEXT,

    transaction_date INTEGER NOT NULL,

    is_recurring INTEGER NOT NULL DEFAULT 0,
    recurring_rule_id TEXT,
    parent_transaction_id TEXT,

    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,
    sync_status TEXT NOT NULL DEFAULT 'synced',

    FOREIGN KEY (wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (from_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (to_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (recurring_rule_id) REFERENCES recurring_rules(id),
    FOREIGN KEY (parent_transaction_id) REFERENCES transactions(id),

    CHECK (type IN ('income', 'expense', 'transfer')),
    CHECK (
        (type IN ('income', 'expense') AND wallet_id IS NOT NULL AND amount_minor IS NOT NULL
         AND from_wallet_id IS NULL AND to_wallet_id IS NULL)
        OR
        (type = 'transfer' AND from_wallet_id IS NOT NULL AND to_wallet_id IS NOT NULL
         AND from_amount_minor IS NOT NULL AND to_amount_minor IS NOT NULL
         AND wallet_id IS NULL AND amount_minor IS NULL)
    )
);

CREATE INDEX idx_transactions_wallet ON transactions(wallet_id);
CREATE INDEX idx_transactions_from ON transactions(from_wallet_id);
CREATE INDEX idx_transactions_to ON transactions(to_wallet_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_deleted ON transactions(deleted_at);
CREATE INDEX idx_transactions_updated ON transactions(updated_at);
CREATE INDEX idx_transactions_recurring ON transactions(recurring_rule_id);
```

При необходимости ослабьте `CHECK`, если SQLite-версия на целевой платформе не поддерживает сложные выражения; тогда те же правила — **только в слое приложения**.

### 4.3 Логика по типам

| `type` | Заполненные поля | Эффект на балансы |
|--------|------------------|-------------------|
| `income` | `wallet_id`, `amount_minor`, `currency` | `current_balance_minor` кошелька += `amount_minor` |
| `expense` | то же | `current_balance_minor` -= `amount_minor` |
| `transfer` | `from_wallet_id`, `to_wallet_id`, `from_amount_minor`, `to_amount_minor` | у кошелька «откуда» -= `from_amount_minor`, у «куда» += `to_amount_minor` (в каждой своей валюте) |

**Пример — зарплата (доход):** +$3 000.00 на `w-sav-…`:

- `type = 'income'`, `wallet_id = 'w-sav-…'`, `amount_minor = 300000`, `currency = 'USD'`, `description = 'Salary Payment'`.

**Пример — покупка (расход):** −$45.67:

- `type = 'expense'`, `wallet_id = 'w-chk-…'`, `amount_minor = 4567`, `currency = 'USD'`, `description = 'Whole Foods Market'`.

**Пример — перевод в одной валюте:** со «Checking» на «Savings» 500.00 USD:

- `type = 'transfer'`, `from_wallet_id`, `to_wallet_id`, `from_amount_minor = 50000`, `to_amount_minor = 50000`, `currency` можно дублировать как валюту операции отображения или оставить валюту «откуда» — главное, чтобы UI и отчёты были согласованы.

---

## 5. Таблица `tags` (теги)

### 5.1 Назначение

Простые метки без жёсткой иерархии категорий: пользователь вводит слово → находим или создаём тег → связываем с транзакцией через `transaction_tags`.

### 5.2 Схема (целевая)

```sql
CREATE TABLE tags (
    id TEXT PRIMARY KEY,
    normalized_name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    color TEXT,
    usage_count INTEGER NOT NULL DEFAULT 0,
    is_favorite INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,
    sync_status TEXT NOT NULL DEFAULT 'synced'
);

-- Уникальность только среди «живых» тегов (soft delete не блокирует имя навсегда)
CREATE UNIQUE INDEX idx_tags_normalized_active
    ON tags(normalized_name)
    WHERE deleted_at IS NULL;

CREATE INDEX idx_tags_deleted ON tags(deleted_at);
CREATE INDEX idx_tags_updated ON tags(updated_at);
```

`normalized_name` — например нижний регистр и обрезка пробелов: «Еда» и « еда » → один тег.

### 5.3 Логика

1. Пользователь ввёл «продукты» → `normalized_name = 'продукты'` → `SELECT id FROM tags WHERE normalized_name = ? AND deleted_at IS NULL`. Нет строки → `INSERT`, есть → взять `id`.
2. После привязки к транзакции можно увеличить `usage_count` для автодополнения и статистики.
3. **`is_favorite`:** закрепить частые теги в UI (как в советах из README).

### 5.4 Пример

| id | normalized_name | display_name | usage_count | deleted_at |
|----|-----------------|--------------|-------------|------------|
| `t-1…` | продукты | продукты | 12 | NULL |

---

## 6. Таблица `transaction_tags` (связь транзакция ↔ тег)

### 6.1 Назначение

Многие ко многим: одна транзакция — несколько тегов, один тег — много транзакций.

### 6.2 Схема

```sql
CREATE TABLE transaction_tags (
    id TEXT PRIMARY KEY,
    transaction_id TEXT NOT NULL,
    tag_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,

    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
    UNIQUE(transaction_id, tag_id)
);

CREATE INDEX idx_transaction_tags_transaction ON transaction_tags(transaction_id);
CREATE INDEX idx_transaction_tags_tag ON transaction_tags(tag_id);
```

### 6.3 Логика

- При **soft delete** транзакции строки в `transaction_tags` обычно **не удаляют** — они остаются для восстановления транзакции вместе с тегами. Физическое удаление транзакции (редкий случай) каскадом сотрёт связи.
- **Пример:** транзакция `tx-99…` с тегами «продукты» и «работа»:

| id | transaction_id | tag_id |
|----|----------------|--------|
| `tt-1…` | `tx-99…` | `t-1…` |
| `tt-2…` | `tx-99…` | `t-2…` |

---

## 7. Таблица `recurring_rules` (правила повторов)

### 7.1 Назначение

Шаблон: «каждый месяц аренда» → по расписанию создаётся строка в `transactions` (с заполненным `recurring_rule_id`), а `next_occurrence` сдвигается.

### 7.2 Схема (целевая)

```sql
CREATE TABLE recurring_rules (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,

    amount_minor INTEGER,
    currency TEXT NOT NULL,

    wallet_id TEXT,
    from_wallet_id TEXT,
    to_wallet_id TEXT,
    from_amount_minor INTEGER,
    to_amount_minor INTEGER,
    exchange_rate REAL,

    description TEXT,

    frequency TEXT NOT NULL,
    interval INTEGER NOT NULL DEFAULT 1,
    start_date INTEGER NOT NULL,
    end_date INTEGER,
    next_occurrence INTEGER NOT NULL,

    is_active INTEGER NOT NULL DEFAULT 1,

    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,
    sync_status TEXT NOT NULL DEFAULT 'synced',

    FOREIGN KEY (wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (from_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (to_wallet_id) REFERENCES wallets(id),

    CHECK (type IN ('income', 'expense', 'transfer')),
    CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly'))
);

CREATE INDEX idx_recurring_next ON recurring_rules(next_occurrence);
CREATE INDEX idx_recurring_active ON recurring_rules(is_active);
CREATE INDEX idx_recurring_deleted ON recurring_rules(deleted_at);
```

Инварианты по полям — **зеркально** таблице `transactions` для того же `type` (лучше проверять в одном месте в коде).

### 7.3 Логика

1. Фоновая задача или открытие приложения: `SELECT * FROM recurring_rules WHERE is_active = 1 AND deleted_at IS NULL AND next_occurrence <= ?`.
2. Для каждого правила: создать `transactions` с `is_recurring = 1`, `recurring_rule_id = …`, обновить балансы кошельков, вычислить новый `next_occurrence` (с учётом `interval` и `frequency`).
3. **`end_date`:** если следующий расчётный момент после `end_date` — правило можно деактивировать (`is_active = 0`).

### 7.4 Пример

Аренда **$1 200.00** каждый месяц с `start_date`, следующее списание `next_occurrence`:

- `type = 'expense'`, `wallet_id`, `amount_minor = 120000`, `currency = 'USD'`, `frequency = 'monthly'`, `interval = 1`.

---

## 8. Таблица `recurring_rule_tags`

### 8.1 Назначение

Теги, которые автоматически навешиваются на **каждую** сгенерированную из правила транзакцию (копирование связей в `transaction_tags` при создании проводки).

### 8.2 Схема

```sql
CREATE TABLE recurring_rule_tags (
    id TEXT PRIMARY KEY,
    recurring_rule_id TEXT NOT NULL,
    tag_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,

    FOREIGN KEY (recurring_rule_id) REFERENCES recurring_rules(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
    UNIQUE(recurring_rule_id, tag_id)
);

CREATE INDEX idx_recurring_tags_rule ON recurring_rule_tags(recurring_rule_id);
CREATE INDEX idx_recurring_tags_tag ON recurring_rule_tags(tag_id);
```

### 8.3 Пример

Правило «аренда» всегда с тегом «дом»:

| recurring_rule_id | tag_id |
|-------------------|--------|
| `rr-rent-…` | `t-home-…` |

При срабатывании правила создаётся транзакция и строка в `transaction_tags` с тем же `tag_id`.

---

## 9. Таблица `sync_log` (очередь синхронизации)

### 9.1 Назначение

Упрощённый журнал: какая таблица, какой `record_id`, какая операция, статус попытки. Полезно до появления полноценного sync-движка.

### 9.2 Схема

```sql
CREATE TABLE sync_log (
    id TEXT PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    operation TEXT NOT NULL,
    sync_status TEXT NOT NULL DEFAULT 'pending',
    attempt_count INTEGER NOT NULL DEFAULT 0,
    last_error TEXT,
    created_at INTEGER NOT NULL,
    synced_at INTEGER
);

CREATE INDEX idx_sync_pending ON sync_log(sync_status);
CREATE INDEX idx_sync_table ON sync_log(table_name);
```

### 9.3 Логика

После локального `INSERT` в `wallets` можно добавить строку: `table_name = 'wallets'`, `record_id = <uuid>`, `operation = 'insert'`, `sync_status = 'pending'`. После успешной отправки на сервер: `sync_status = 'synced'`, `synced_at = now`.

**Пример:**

| table_name | record_id | operation | sync_status |
|------------|-----------|-----------|---------------|
| transactions | `tx-99…` | update | pending |

Имеет смысл периодически **чистить** успешно синхронизированные старые записи, чтобы таблица не росла бесконечно.

---

## 10. Сквозные сценарии (пошагово)

### 10.1 Создание кошелька и начальный баланс

1. `INSERT INTO wallets (…, initial_balance_minor, current_balance_minor, …)` — оба поля равны стартовой сумме в центах.
2. Опционально: отдельная транзакция типа `income` «Начальный баланс» для аудита — тогда стартовый баланс кошелька согласуется с суммой проводок; если не хотите шум в списке — оставьте только поля кошелька, но тогда **история ≠ баланс** до первой реальной проводки.

### 10.2 Одна покупка с новым тегом

1. `BEGIN TRANSACTION`
2. Вставить `transactions` (expense), обновить `wallets.current_balance_minor`.
3. Найти/создать `tags`, `INSERT INTO transaction_tags`.
4. `UPDATE tags SET usage_count = usage_count + 1, updated_at = …`
5. `COMMIT`

### 10.3 Перевод EUR → USD

1. Одна строка `transactions` с `type = 'transfer'` и заполненными `from_*` / `to_*`.
2. Уменьшить баланс EUR-кошелька на `from_amount_minor`, увеличить USD-кошелёк на `to_amount_minor`.

### 10.4 Soft delete транзакции

1. `UPDATE transactions SET deleted_at = ?, updated_at = ?, sync_status = 'pending' WHERE id = ?`
2. **Откатить** изменение баланса кошелька (на ту же величину, что применяли при создании), в той же транзакции БД.
3. Список операций в UI: `WHERE deleted_at IS NULL`.

---

## 11. Экспорт и импорт (логика)

- **Полный дамп:** выгрузить все таблицы в JSON (массивы объектов), порядок импорта: `wallets` → `tags` → `recurring_rules` → `transactions` → `transaction_tags` → `recurring_rule_tags` → `sync_log` (или последний опустить).
- **Инкремент:** `WHERE updated_at > last_export_ts` по каждой сущности, на стороне импорта — upsert по `id`.
- UUID гарантируют отсутствие конфликтов id при слиянии двух офлайн-веток; разрешение **конфликтов полей** — отдельная политика приложения (не часть этой схемы).

---

## 12. Краткий чеклист для разработчика

- [ ] Все изменения денег и баланса — в **одной** SQL-транзакции.
- [ ] Инварианты `transactions.type` соблюдены (`CHECK` и/или код).
- [ ] Теги: уникальность по `normalized_name` только для `deleted_at IS NULL`.
- [ ] `PRAGMA foreign_keys = ON`.
- [ ] Понятная договорённость по `exchange_rate` и отображению переводов.
- [ ] Ротация или очистка `sync_log` после стабильной синхронизации.

---

*Документ отражает целевую модель fiin и может эволюционировать (например, отдельная таблица `currencies`, поле `user_id` при появлении аккаунтов, версионирование схемы `schema_migrations`).*
