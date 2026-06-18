#!/bin/sh
# ═══════════════════════════════════════════════════════════════
#  SECURITY GATE — by 3da4ya © 2026
#  Сканує ./api перед деплоєм. Exit 1 = блокує всі залежні сервіси
# ═══════════════════════════════════════════════════════════════

SCAN_DIR="/scan/api"
FOUND=0

echo "╔══════════════════════════════════════╗"
echo "║  🔒 SECURITY GATE — 3da4ya © 2026   ║"
echo "╚══════════════════════════════════════╝"
echo "Сканую: $SCAN_DIR"
echo ""

# ── Список небезпечних патернів ──────────────────────────────
check_pattern() {
  PATTERN="$1"
  DESC="$2"
  RESULTS=$(grep -rn --include="*.js" --include="*.ts" --include="*.sh" "$PATTERN" "$SCAN_DIR" 2>/dev/null)
  if [ -n "$RESULTS" ]; then
    echo "  ⛔ ЗНАЙДЕНО: $DESC"
    echo "$RESULTS" | head -5
    FOUND=$((FOUND + 1))
  fi
}

echo "[ Перевірка небезпечних викликів ]"
check_pattern "eval("              "eval() — виконання довільного коду"
check_pattern "new Function("     "new Function() — динамічний код"
check_pattern "child_process"     "child_process — виконання команд ОС"
check_pattern "exec("             "exec() — виконання системних команд"
check_pattern "__dirname.*\.\./"  "Path traversal — вихід з директорії"
check_pattern "process\.env\b"    "WARNING: прямий доступ до process.env (перевір)"

echo ""
echo "[ Перевірка захисту секретів ]"
# Перевірка чи немає хардкоду паролів
if grep -rn --include="*.js" "password\s*=\s*['\"][^'\"]\{6,\}" "$SCAN_DIR" 2>/dev/null | grep -v "process\.env"; then
  echo "  ⛔ ЗНАЙДЕНО: Хардкод пароля в коді!"
  FOUND=$((FOUND + 1))
else
  echo "  ✅ Хардкод паролів не знайдено"
fi

echo ""

# ── Результат ─────────────────────────────────────────────────
if [ "$FOUND" -gt 0 ]; then
  echo "══════════════════════════════════════"
  echo "  🚨 ДЕПЛОЙ ЗАБЛОКОВАНО!"
  echo "  Знайдено вразливостей: $FOUND"
  echo "  Виправ код і перезапусти екосистему."
  echo "══════════════════════════════════════"
  exit 1
else
  echo "══════════════════════════════════════"
  echo "  ✅ SECURITY GATE: PASSED"
  echo "  Вразливостей не знайдено. Деплой дозволено."
  echo "══════════════════════════════════════"
  exit 0
fi
