# ⚡ All-in-One AI Cloud Workspace
**by 3da4ya © 2026** — From the pain of virtualization to an autonomous PaaS cloud in 30 seconds

---

## Project structure

```
all-in-one/
├── docker-compose.yml          # Orchestrator — 11 services
├── .env.example                # Environment variables template (copy to .env)
├── .gitignore                  # Secrets protection
├── init-cloud.sh               # 🚀 Main launch script
│
├── frontend/
│   └── index.html              # Web UI dashboard
│
├── nginx/
│   └── nginx.conf              # Reverse proxy config to the API
│
├── api/
│   ├── index.js                # Express API server
│   └── package.json
│
├── db/
│   └── init.sql                # PostgreSQL schema initialization
│
├── prometheus/
│   ├── prometheus.yml          # Metrics collection config
│   └── alerts.yml              # Alert rules
│
├── grafana/
│   └── provisioning/
│       ├── datasources/        # Auto-attach Prometheus
│       └── dashboards/         # Auto-load dashboards
│
├── scripts/
│   ├── scan.sh                 # Security Gate scanner
│   └── backup.sh               # Auto DB backup
│
└── backups/                    # .sql.gz backups live here
```

---

## Quick start

```bash
# 1. Clone / copy the project
cd all-in-one

# 2. Fill in your secrets
cp .env.example .env
nano .env   # fill in all FILL_ME and CHANGE_ME values

# 3. Launch it
chmod +x init-cloud.sh && ./init-cloud.sh
```

---

## What you need to do (manual steps)

### 1. Fill in `.env`

| Variable | Where to get it |
|----------|-----------------|
| `POSTGRES_PASSWORD` | Pick a strong password |
| `GRAFANA_PASSWORD` | Pick a strong password |
| `GOTIFY_PASSWORD` | Pick a password for Gotify login |
| `GOTIFY_APP_TOKEN` | After first login: http://localhost:8080 → Apps → Create App → copy the token |
| `TELEGRAM_BOT_TOKEN` | @BotFather → /newbot |
| `TELEGRAM_CHAT_ID` | Message your bot, then: `https://api.telegram.org/bot<TOKEN>/getUpdates` |
| `ZEROTIER_NETWORK_ID` | my.zerotier.com → Create Network → 16-character ID |

### 2. Gotify — get an APP TOKEN

1. Open http://localhost:8080
2. Username: `admin` / password from `.env` (`GOTIFY_PASSWORD`)
3. Apps → **Create App** → enter the name "3da4ya-alerts"
4. Copy the token → paste into `.env` as `GOTIFY_APP_TOKEN`
5. `docker compose restart api-server`

### 3. ZeroTier — authorize the node

After the ecosystem comes up:
1. `docker exec zerotier_workspace zerotier-cli info` — copy the Node ID
2. Go to my.zerotier.com → your network → **Members**
3. Find the node → check ✅ Auth

### 4. Grafana — import the cAdvisor dashboard

1. Open http://localhost:3000 (admin / `GRAFANA_PASSWORD`)
2. Dashboards → **Import**
3. Enter ID: **893** → Load → Import
4. Datasource: Prometheus → Import

---

## Ports

| Service | Port | URL |
|---------|------|-----|
| Web UI | 80 | http://localhost |
| Grafana | 3000 | http://localhost:3000 |
| Gotify | 8080 | http://localhost:8080 |
| cAdvisor | 8081 | http://localhost:8081 |
| Prometheus | 9090 | http://localhost:9090 |

---

## Useful commands

```bash
docker compose ps                    # status of all containers
docker compose logs -f api-server    # API logs
docker compose stop db-server        # simulate an outage (Situation Center)
docker compose start db-server       # recovery
docker compose down                  # stop everything
docker compose down -v               # stop + remove volumes (CAREFUL!)
```

---

Distributed under the **Apache License 2.0**. See [LICENSE](LICENSE) for the full text. See [NOTICE](NOTICE) for attribution.
