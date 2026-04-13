# fiin

The best finnace budgeting App.

## Getting Started


# Database Structure
### Note
Я создаю мобильное приложение очень минималистичное для учета бюджета, я хочу чтобы ты посмотрел на скриншоты проанализировал их и дал мне лучшую модель для составления локальной базы данных чтобы я правильно и надежно мог хранить данные кошельков и транзакций внутри, я так же хочу чтобы в будущем эта модель базы данных правильно и легко была маштабируема, легко можно было от туда экспортировать данные, легко импортировать и в общем чтобы я не сталкивался в будущем с проблемами которые обычно бывают для таких приложений, если хочешь если есть вопросы можешь справшивать я отвечу чтобы ты лучше мог понять идею приложения

Q: Планируете ли синхронизацию между устройствами или только локальное хранение?
A: Планирую синхронизацию в будущем
Q: Какие типы транзакций нужно поддерживать?
A: Все вышеперечисленное
Q: Нужна ли категоризация и теги для транзакций?
A: Там на экране ввода транзакции над кнопкой выбора даты будет маленькое поле ввода пользователь сможет просто написав  слово создать тэг в таблице Tags если ранее оно не было в этой таблице если было то айди созданного ранее тэга просто подставляется в модель транзакции и в будущем мы сможем создать отдельную страницу прогресса чтобы на основе тэгов брать нужные транзакции и анализировать их, ну что-то типо такого хочу реализовать не знаю на сколько это будет удобно думаю что очень удобно, не нужно будет следить за категориями и всеми теми сложными логиками тут все должно быть просто понятно и удобно, если у тебя есть совет можешь дать его


🗄️ Оптимальная модель базы данных
Ключевые принципы:

UUID вместо автоинкремента (для будущей синхронизации)

1. Wallets (Кошельки)
```sql
CREATE TABLE wallets (
    id TEXT PRIMARY KEY,                    -- UUID
    name TEXT NOT NULL,
    currency TEXT NOT NULL,                 -- ISO код (USD, EUR, RUB)
    initial_balance REAL NOT NULL DEFAULT 0,
    current_balance REAL NOT NULL DEFAULT 0,
    color TEXT,                             -- HEX цвет (#FF5733)
    icon TEXT,                              -- emoji или название иконки
    is_primary INTEGER DEFAULT 0,           -- булево (0/1)
    is_excluded_from_total INTEGER DEFAULT 0, -- исключить из общего баланса
    sort_order INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,            -- Unix timestamp
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,                     -- Soft delete
    sync_status TEXT DEFAULT 'synced'       -- synced/pending/conflict
);

CREATE INDEX idx_wallets_deleted ON wallets(deleted_at);
CREATE INDEX idx_wallets_updated ON wallets(updated_at);
```

2. Transactions (Транзакции)
```sql
CREATE TABLE transactions (
    id TEXT PRIMARY KEY,                    -- UUID
    type TEXT NOT NULL,                     -- income/expense/transfer
    amount REAL NOT NULL,
    currency TEXT NOT NULL,
    
    -- Для обычных транзакций
    wallet_id TEXT,                         -- NULL для трансферов
    
    -- Для трансферов
    from_wallet_id TEXT,
    to_wallet_id TEXT,
    from_amount REAL,                       -- Сумма списания
    to_amount REAL,                         -- Сумма зачисления
    exchange_rate REAL,                     -- Курс конвертации
    
    description TEXT,
    notes TEXT,
    
    transaction_date INTEGER NOT NULL,      -- Unix timestamp даты транзакции
    
    -- Для повторяющихся
    is_recurring INTEGER DEFAULT 0,
    recurring_rule_id TEXT,                 -- Ссылка на правило
    parent_transaction_id TEXT,             -- Ссылка на родительскую транзакцию
    
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,
    sync_status TEXT DEFAULT 'synced',
    
    FOREIGN KEY (wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (from_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (to_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (recurring_rule_id) REFERENCES recurring_rules(id),
    FOREIGN KEY (parent_transaction_id) REFERENCES transactions(id)
);

CREATE INDEX idx_transactions_wallet ON transactions(wallet_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_deleted ON transactions(deleted_at);
CREATE INDEX idx_transactions_updated ON transactions(updated_at);
CREATE INDEX idx_transactions_recurring ON transactions(recurring_rule_id);
```

3. Tags (Теги)
```sql
CREATE TABLE tags (
    id TEXT PRIMARY KEY,                    -- UUID
    name TEXT NOT NULL UNIQUE,              -- Уникальное имя тега
    color TEXT,                             -- Опциональный цвет
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,
    sync_status TEXT DEFAULT 'synced'
);

CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_tags_deleted ON tags(deleted_at);
```

4. Transaction_Tags (Связь многие-ко-многим)
```sql
CREATE TABLE transaction_tags (
    id TEXT PRIMARY KEY,                    -- UUID
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

5. Recurring_Rules (Правила повторения)
```sql
CREATE TABLE recurring_rules (
    id TEXT PRIMARY KEY,                    -- UUID
    type TEXT NOT NULL,                     -- income/expense/transfer
    amount REAL NOT NULL,
    currency TEXT NOT NULL,
    
    wallet_id TEXT,
    from_wallet_id TEXT,
    to_wallet_id TEXT,
    
    description TEXT,
    
    frequency TEXT NOT NULL,                -- daily/weekly/monthly/yearly
    interval INTEGER DEFAULT 1,             -- каждые N периодов
    start_date INTEGER NOT NULL,
    end_date INTEGER,                       -- NULL = бесконечно
    
    next_occurrence INTEGER NOT NULL,       -- Дата следующего создания
    
    is_active INTEGER DEFAULT 1,
    
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER,
    sync_status TEXT DEFAULT 'synced',
    
    FOREIGN KEY (wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (from_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY (to_wallet_id) REFERENCES wallets(id)
);

CREATE INDEX idx_recurring_next ON recurring_rules(next_occurrence);
CREATE INDEX idx_recurring_active ON recurring_rules(is_active);
```

6. Recurring_Rule_Tags (Теги для правил)
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

7. Sync_Log (Для будущей синхронизации)
```sql
CREATE TABLE sync_log (
    id TEXT PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id TEXT NOT NULL,
    operation TEXT NOT NULL,                -- insert/update/delete
    sync_status TEXT DEFAULT 'pending',     -- pending/synced/failed
    attempt_count INTEGER DEFAULT 0,
    last_error TEXT,
    created_at INTEGER NOT NULL,
    synced_at INTEGER
);

CREATE INDEX idx_sync_pending ON sync_log(sync_status);
CREATE INDEX idx_sync_table ON sync_log(table_name);
```

🎯 Ключевые преимущества этой модели:
✅ Масштабируемость:

UUID готовы для мультидевайсной синхронизации
Soft delete позволяет восстанавливать данные
sync_status отслеживает состояние синхронизации

✅ Гибкость тегов:

Автоматическое создание тегов при вводе
Многие теги на одну транзакцию
Легкая фильтрация и аналитика

✅ Поддержка всех типов транзакций:

Доход/Расход/Перевод в одной таблице
Мультивалютные переводы с курсом
Повторяющиеся транзакции

✅ Экспорт/Импорт:

Все в JSON одним запросом
Timestamps для инкрементального бэкапа
Связи через UUID легко восстанавливаются


💡 Мой совет по тегам:
Ваша идея отличная! Но добавьте:

Автодополнение - показывайте ранее использованные теги
Частотность - храните счетчик использований тега
Быстрые теги - закрепите топ-5 тегов для быстрого доступа
Цветовое кодирование - позвольте назначить цвет тегу

sql-- Добавьте в таблицу tags:
ALTER TABLE tags ADD COLUMN usage_count INTEGER DEFAULT 0;
ALTER TABLE tags ADD COLUMN is_favorite INTEGER DEFAULT 0;
Хотите, чтобы я создал готовые SQL-скрипты для инициализации БД или примеры кода для работы с этой моделью?