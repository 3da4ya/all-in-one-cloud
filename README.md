# ⚡ All-in-One AI Cloud Workspace
**by 3da4ya © 2026** — Від болю віртуалізації до автономного PaaS-хмари за 30 секунд

---

## Структура проекту

```
all-in-one/
├── docker-compose.yml          # Оркестратор — 11 сервісів
├── .env.example                # Шаблон змінних (скопіюй в .env)
├── .gitignore                  # Захист секретів
├── init-cloud.sh               # 🚀 Головний скрипт запуску
│
├── frontend/
│   └── index.html              # Дашборд веб-інтерфейсу
│
├── nginx/
│   └── nginx.conf              # Конфіг проксі до API
│
├── api/
│   ├── index.js                # Express API-сервер
│   └── package.json
│
├── db/
│   └── init.sql                # Ініціалізація схеми PostgreSQL
│
├── prometheus/
│   ├── prometheus.yml          # Конфіг збору метрик
│   └── alerts.yml              # Правила алертів
│
├── grafana/
│   └── provisioning/
│       ├── datasources/        # Автопідключення Prometheus
│       └── dashboards/         # Автозавантаження дашбордів
│
├── scripts/
│   ├── scan.sh                 # Security Gate сканер
│   └── backup.sh               # Авто-бекап БД
│
└── backups/                    # Тут живуть .sql.gz бекапи
```

---

## Швидкий старт

```bash
# 1. Клонуй / скопіюй проект
cd all-in-one

# 2. Заповни секрети
cp .env.example .env
nano .env   # заповни всі FILL_ME і CHANGE_ME

# 3. Запускай
chmod +x init-cloud.sh && ./init-cloud.sh
```

---

## Що потрібно від тебе (ручні дії)

### 1. Заповнити .env

| Змінна | Де взяти |
|--------|----------|
| `POSTGRES_PASSWORD` | Придумай сильний пароль |
| `GRAFANA_PASSWORD` | Придумай сильний пароль |
| `GOTIFY_PASSWORD` | Придумай пароль для входу в Gotify |
| `GOTIFY_APP_TOKEN` | Після першого входу: http://localhost:8080 → Apps → Create App → скопіюй token |
| `TELEGRAM_BOT_TOKEN` | @BotFather → /newbot |
| `TELEGRAM_CHAT_ID` | Напиши боту, потім: `https://api.telegram.org/bot<TOKEN>/getUpdates` |
| `ZEROTIER_NETWORK_ID` | my.zerotier.com → Create Network → 16-символьний ID |

### 2. Gotify — отримати APP TOKEN

1. Відкрий http://localhost:8080
2. Логін: `admin` / пароль з `.env` (GOTIFY_PASSWORD)
3. Apps → **Create App** → введи назву "3da4ya-alerts"
4. Скопіюй token → встав в `.env` як `GOTIFY_APP_TOKEN`
5. `docker compose restart api-server`

### 3. ZeroTier — авторизація ноди

Після запуску екосистеми:
1. `docker exec zerotier_workspace zerotier-cli info` — скопіюй Node ID
2. Зайди на my.zerotier.com → твоя мережа → **Members**
3. Знайди ноду → поставь ✅ Auth

### 4. Grafana — імпорт дашборду cAdvisor

1. Відкрий http://localhost:3000 (admin / GRAFANA_PASSWORD)
2. Dashboards → **Import**
3. Введи ID: **893** → Load → Import
4. Datasource: Prometheus → Import

---

## Порти

| Сервіс | Порт | URL |
|--------|------|-----|
| Веб-інтерфейс | 80 | http://localhost |
| Grafana | 3000 | http://localhost:3000 |
| Gotify | 8080 | http://localhost:8080 |
| cAdvisor | 8081 | http://localhost:8081 |
| Prometheus | 9090 | http://localhost:9090 |

---

## Корисні команди

```bash
docker compose ps                    # статус всіх контейнерів
docker compose logs -f api-server    # логи API
docker compose stop db-server        # симуляція аварії (Ситуаційний Центр)
docker compose start db-server       # відновлення
docker compose down                  # зупинити все
docker compose down -v               # зупинити + видалити volumes (ОБЕРЕЖНО!)
```

---

© 2026 Олександр Владиславович (3da4ya). Усі права захищені.
