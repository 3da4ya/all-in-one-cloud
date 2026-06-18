#!/bin/sh
# ═══════════════════════════════════════════════════════════════
#  AUTO-BACKUP — by 3da4ya © 2026
#  Щоденний pg_dump, ротація 7 днів, алерт в Telegram
# ═══════════════════════════════════════════════════════════════

BACKUP_DIR="/backups"
RETENTION_DAYS=7

tg_alert() {
  MSG="$1"
  if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
    wget -qO- \
      "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      --post-data "chat_id=${TELEGRAM_CHAT_ID}&text=${MSG}&parse_mode=Markdown" \
      > /dev/null 2>&1
  fi
}

echo "[ DB-BACKUP ] Сервіс запущено, чекаємо на БД..."
sleep 5

while true; do
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  FILE="$BACKUP_DIR/backup_${POSTGRES_DB}_${TIMESTAMP}.sql.gz"

  echo "[ DB-BACKUP ] $(date) — Починаю бекап..."

  # Виконати pg_dump і стиснути
  pg_dump -h "$DB_HOST" -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$FILE"

  if [ $? -eq 0 ]; then
    SIZE=$(du -sh "$FILE" | cut -f1)
    echo "[ DB-BACKUP ] ✅ Успішно: $FILE ($SIZE)"
    tg_alert "✅ *DB Backup OK*%0AБД: ${POSTGRES_DB}%0AРозмір: ${SIZE}%0AЧас: $(date)"

    # Ротація — видалити файли старші RETENTION_DAYS днів
    DELETED=$(find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -print -delete | wc -l)
    [ "$DELETED" -gt 0 ] && echo "[ DB-BACKUP ] 🗑 Видалено старих бекапів: $DELETED"
  else
    echo "[ DB-BACKUP ] ❌ ПОМИЛКА бекапу!"
    tg_alert "🚨 *DB Backup FAILED*%0AБД: ${POSTGRES_DB}%0AЧас: $(date)%0AПеревір контейнер db-backup!"
    rm -f "$FILE"
  fi

  echo "[ DB-BACKUP ] Наступний бекап через 24 год..."
  sleep 86400
done
