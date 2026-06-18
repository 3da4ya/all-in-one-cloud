#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  ALL-IN-ONE AI CLOUD WORKSPACE — INIT SCRIPT
#  by 3da4ya © 2026
#  Використання: chmod +x init-cloud.sh && ./init-cloud.sh
# ═══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   ALL-IN-ONE AI CLOUD WORKSPACE — by 3da4ya     ║"
echo "║   Ініціалізація екосистеми...                    ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── [1] Docker ────────────────────────────────────────────────
echo -e "${YELLOW}[1/5] Перевірка Docker...${NC}"
if ! command -v docker &> /dev/null; then
  echo "Docker не знайдено. Встановлення..."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $USER
  echo -e "${GREEN}Docker встановлено!${NC}"
else
  echo -e "${GREEN}Docker знайдено: $(docker --version)${NC}"
fi

# ── [2] .env ──────────────────────────────────────────────────
echo -e "${YELLOW}[2/5] Перевірка .env...${NC}"
if [ ! -f ".env" ]; then
  if [ -f ".env.example" ]; then
    cp .env.example .env
    echo -e "${RED}⚠  УВАГА: .env створено з шаблону!${NC}"
    echo -e "${RED}   Заповни всі FILL_ME та CHANGE_ME перед запуском!${NC}"
    echo ""
    echo "   Відкрий файл: nano .env"
    echo ""
    read -p "Натисни Enter після заповнення .env, або Ctrl+C для виходу..."
  else
    echo -e "${RED}❌ Файл .env.example не знайдено!${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}.env знайдено${NC}"
fi

# ── [3] Перевірка заповненості .env ──────────────────────────
echo -e "${YELLOW}[3/5] Валідація .env...${NC}"
source .env 2>/dev/null || true

ERRORS=0
check_var() {
  local VAR_NAME="$1"
  local VAR_VAL="${!VAR_NAME}"
  if [ -z "$VAR_VAL" ] || [[ "$VAR_VAL" == *"FILL_ME"* ]] || [[ "$VAR_VAL" == *"CHANGE_ME"* ]]; then
    echo -e "  ${RED}❌ $VAR_NAME не заповнено${NC}"
    ERRORS=$((ERRORS+1))
  else
    echo -e "  ${GREEN}✅ $VAR_NAME${NC}"
  fi
}

check_var "POSTGRES_PASSWORD"
check_var "GRAFANA_PASSWORD"
check_var "GOTIFY_PASSWORD"
# Telegram і ZeroTier опціональні при першому запуску

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}❌ Заповни $ERRORS змінних у .env і запусти знову!${NC}"
  exit 1
fi

# ── [4] Права на скрипти ─────────────────────────────────────
echo -e "${YELLOW}[4/5] Налаштування прав...${NC}"
chmod +x scripts/*.sh 2>/dev/null || true
mkdir -p backups
echo -e "${GREEN}Готово${NC}"

# ── [5] Запуск ───────────────────────────────────────────────
echo -e "${YELLOW}[5/5] Запуск екосистеми...${NC}"
docker compose pull --quiet
docker compose up -d --remove-orphans

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════╗"
echo "║   ✅ ЕКОСИСТЕМА УСПІШНО РОЗГОРНУТА!             ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║   🌐 Веб-інтерфейс:  http://localhost           ║"
echo "║   📊 Grafana:        http://localhost:3000      ║"
echo "║   🔔 Gotify:         http://localhost:8080      ║"
echo "║   🔭 Prometheus:     http://localhost:9090      ║"
echo "║   📦 cAdvisor:       http://localhost:8081      ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║   🔍 Логи: docker compose logs -f               ║"
echo "║   🛑 Стоп: docker compose down                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Статус контейнерів ────────────────────────────────────────
echo -e "${CYAN}Статус контейнерів:${NC}"
docker compose ps
