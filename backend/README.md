# Taza Grocery — Backend API

FastAPI + async SQLAlchemy + PostgreSQL (Neon). JWT auth with bcrypt password hashing.

## Setup
```bash
pip install -r requirements.txt
cp .env.example .env          # then set DATABASE_URL and SECRET_KEY
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```
- Interactive docs: http://localhost:8000/docs
- Tables are auto-created and seed data inserted on first startup.

## Environment variables
| Var | Required | Description |
|-----|----------|-------------|
| `DATABASE_URL` | yes | Postgres URL (e.g. Neon). `postgres://` / `postgresql://` schemes are auto-normalized to asyncpg. |
| `SECRET_KEY` | recommended | JWT signing key. Set a strong value in production. |

> The app strips libpq query params (`sslmode`, `channel_binding`) that asyncpg doesn't understand and applies SSL automatically for managed hosts (Neon, Supabase, RDS, Render).

## Default admin
Seeded on first run — phone `+923001234567`, password `admin123`.

## Structure
```
app/
  api/v1/      auth, products, categories, cart, orders, favorites, banners, upload, admin
  core/        config, security (JWT + hashing)
  database/    async engine & session
  models/      SQLAlchemy models
  schemas/     Pydantic request/response models
  main.py      app factory, CORS, startup seeding
```

## Auth
Send `Authorization: Bearer <token>` on protected routes. Admin-only routes additionally require `role == "admin"`.
