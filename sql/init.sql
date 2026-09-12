-- Создание схемы данных
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    merchant_category VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    is_fraud INT NOT NULL DEFAULT 0
);

-- Индексация под временные ряды (BRIN для оптимизации размера индекса)
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions USING BRIN (created_at);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions (user_id);

-- Генерация 100 000 синтетических транзакций за последние 90 дней
INSERT INTO transactions (user_id, amount, merchant_category, created_at, is_fraud)
SELECT 
    FLOOR(RANDOM() * 5000 + 1)::INT AS user_id,
    ROUND((RANDOM() * 15000 + 10)::NUMERIC, 2) AS amount,
    (ARRAY['groceries', 'electronics', 'apparel', 'travel', 'crypto', 'transfers'])[FLOOR(RANDOM() * 6 + 1)] AS merchant_category,
    NOW() - (RANDOM() * INTERVAL '90 days') AS created_at,
    CASE WHEN RANDOM() < 0.03 THEN 1 ELSE 0 END AS is_fraud
FROM generate_series(1, 100000);