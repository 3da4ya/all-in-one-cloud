-- ═══════════════════════════════════════════════════════════════
--  ALL-IN-ONE — Ініціалізація схеми БД — by 3da4ya © 2026
-- ═══════════════════════════════════════════════════════════════

-- Таблиця логів подій системи
CREATE TABLE IF NOT EXISTS system_events (
    id         SERIAL PRIMARY KEY,
    event_type VARCHAR(50)  NOT NULL,
    service    VARCHAR(100) NOT NULL,
    message    TEXT,
    severity   VARCHAR(20)  DEFAULT 'info',
    created_at TIMESTAMP    DEFAULT NOW()
);

-- Таблиця стану сервісів
CREATE TABLE IF NOT EXISTS service_status (
    service_name VARCHAR(100) PRIMARY KEY,
    status       VARCHAR(20)  NOT NULL DEFAULT 'unknown',
    last_check   TIMESTAMP    DEFAULT NOW(),
    details      JSONB
);

-- Початкові записи
INSERT INTO service_status (service_name, status, details) VALUES
    ('web-server',   'ok', '{"port": 80}'),
    ('api-server',   'ok', '{"port": 3001}'),
    ('db-server',    'ok', '{"port": 5432}'),
    ('redis-cache',  'ok', '{"port": 6379, "maxmemory": "256mb"}'),
    ('prometheus',   'ok', '{"port": 9090}'),
    ('grafana',      'ok', '{"port": 3000}')
ON CONFLICT (service_name) DO NOTHING;

-- Індекс для швидкого пошуку по часу
CREATE INDEX IF NOT EXISTS idx_events_created ON system_events(created_at DESC);
