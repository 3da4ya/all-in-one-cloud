// ═══════════════════════════════════════════════════════════════
//  ALL-IN-ONE API SERVER — by 3da4ya © 2026
// ═══════════════════════════════════════════════════════════════
'use strict';

const express  = require('express');
const { Pool } = require('pg');
const { createClient } = require('redis');
const fetch    = require('node-fetch');

const app  = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());

// ── POSTGRES ──────────────────────────────────────────────────
const db = new Pool({
  host:     process.env.DB_HOST     || 'db-server',
  port:     parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME     || 'app_db',
  user:     process.env.DB_USER     || 'admin',
  password: process.env.DB_PASSWORD || '',
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

// ── REDIS ─────────────────────────────────────────────────────
const redis = createClient({
  socket: {
    host: process.env.REDIS_HOST || 'redis-cache',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    reconnectStrategy: retries => Math.min(retries * 100, 5000),
  }
});
redis.on('error', err => console.error('[Redis] Error:', err.message));
redis.connect().then(() => console.log('[Redis] Connected'));

// ── АЛЕРТИ ───────────────────────────────────────────────────
async function sendAlert(title, message, priority = 5) {
  // Gotify
  try {
    if (process.env.GOTIFY_URL && process.env.GOTIFY_TOKEN) {
      await fetch(process.env.GOTIFY_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-Gotify-Key': process.env.GOTIFY_TOKEN },
        body: JSON.stringify({ title, message, priority }),
      });
    }
  } catch (e) { console.error('[Gotify] Alert failed:', e.message); }

  // Telegram
  try {
    if (process.env.TG_BOT_TOKEN && process.env.TG_CHAT_ID) {
      const icon = priority >= 8 ? '🚨' : priority >= 5 ? '⚠️' : 'ℹ️';
      await fetch(`https://api.telegram.org/bot${process.env.TG_BOT_TOKEN}/sendMessage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          chat_id: process.env.TG_CHAT_ID,
          text: `${icon} *СИТУАЦІЙНИЙ ЦЕНТР*\n*${title}*\n${message}`,
          parse_mode: 'Markdown',
        }),
      });
    }
  } catch (e) { console.error('[Telegram] Alert failed:', e.message); }
}

// ── HEALTH CHECK ──────────────────────────────────────────────
app.get('/health', async (req, res) => {
  const checks = { api: 'ok', db: 'unknown', redis: 'unknown' };
  let httpStatus = 200;

  // перевірка DB
  try {
    await db.query('SELECT 1');
    checks.db = 'ok';
  } catch (e) {
    checks.db = 'error: ' + e.message;
    httpStatus = 503;
    await sendAlert('КРИТИЧНИЙ ЗБІЙ! db-server недоступна!', e.message, 10);
  }

  // перевірка Redis
  try {
    await redis.ping();
    checks.redis = 'ok';
  } catch (e) {
    checks.redis = 'error: ' + e.message;
    httpStatus = httpStatus === 200 ? 503 : httpStatus;
  }

  res.status(httpStatus).json({ status: httpStatus === 200 ? 'ok' : 'degraded', checks, ts: new Date().toISOString() });
});

// ── МЕТРИКИ (для Prometheus) ──────────────────────────────────
app.get('/metrics', async (req, res) => {
  let dbOk = 0, redisOk = 0;
  try { await db.query('SELECT 1');    dbOk = 1;    } catch {}
  try { await redis.ping();            redisOk = 1; } catch {}

  res.set('Content-Type', 'text/plain');
  res.send([
    '# HELP api_db_up Database reachability (1=up, 0=down)',
    '# TYPE api_db_up gauge',
    `api_db_up ${dbOk}`,
    '# HELP api_redis_up Redis reachability (1=up, 0=down)',
    '# TYPE api_redis_up gauge',
    `api_redis_up ${redisOk}`,
    '# HELP api_up API reachability',
    '# TYPE api_up gauge',
    'api_up 1',
  ].join('\n'));
});

// ── DEMO: кешований ендпоінт ──────────────────────────────────
app.get('/data', async (req, res) => {
  const cacheKey = 'data:main';
  try {
    const cached = await redis.get(cacheKey);
    if (cached) return res.json({ source: 'cache', data: JSON.parse(cached) });

    const result = await db.query('SELECT NOW() AS ts, current_database() AS db');
    const data   = result.rows[0];
    await redis.setEx(cacheKey, 60, JSON.stringify(data)); // TTL 60 сек
    res.json({ source: 'db', data });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── СТАРТ ─────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`[API] Running on port ${PORT}`);
  sendAlert('Екосистема запущена', `API-сервер стартував на порту ${PORT}`, 3);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('[API] SIGTERM received, shutting down...');
  await db.end();
  await redis.quit();
  process.exit(0);
});
