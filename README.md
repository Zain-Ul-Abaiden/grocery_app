# 🛒 Taza Grocery — Full-Stack Grocery Delivery Platform

A Cartfly-style online grocery store: customers browse & order from a mobile app, the store owner manages everything from a web admin panel, all backed by a FastAPI + PostgreSQL API.

Simple phone + password auth (no coins / no referral system). Supports product **discounts**, live stock, and order status tracking.

---

## 📦 Project Structure

| Folder | Stack | Purpose |
|--------|-------|---------|
| [`backend/`](backend) | FastAPI · SQLAlchemy (async) · PostgreSQL (Neon) · JWT | REST API + auth + admin endpoints |
| [`admin/`](admin) | Next.js 16 · React 19 · Tailwind CSS | Store owner web dashboard (laptop) |
| [`frontend/`](frontend) | Flutter · Riverpod · Dio · GoRouter | Customer mobile app (Android/iOS) |

---

## 🚀 Quick Start

### 1. Backend (port 8000)
```bash
cd backend
pip install -r requirements.txt
# Create .env from the example and set your DATABASE_URL
cp .env.example .env
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```
- API docs: http://localhost:8000/docs
- On first run it auto-creates tables and seeds categories, products, and a default admin.

### 2. Admin Panel (port 3000)
```bash
cd admin
npm install
npm run dev
```
- Open http://localhost:3000 and log in.
- API base URL is configurable via `NEXT_PUBLIC_API_URL` (defaults to `http://localhost:8000/api/v1`).

### 3. Mobile App
```bash
cd frontend
flutter pub get
flutter run
```
- Set the backend host in [`lib/core/constants/api_endpoints.dart`](frontend/lib/core/constants/api_endpoints.dart) (`_host`) to your PC's LAN IP so a physical phone on the same Wi-Fi can reach it.
- Ensure your firewall allows inbound TCP **8000**.

---

## 🔑 Default Admin Login
| Field | Value |
|-------|-------|
| Phone | `+923001234567` |
| Password | `admin123` |

> Change this in production. Admin role is required to access the admin panel and protected endpoints.

---

## ✨ Features

**Customer app**
- Phone-based signup / login (JWT, persisted securely)
- Browse by category, live search
- Product detail with discount pricing & stock state
- Cart (add / update / remove, stock-validated)
- Cash-on-delivery checkout
- Order history & live status tracking (Urdu labels)

**Admin panel**
- Secure login (admin-only)
- Dashboard: revenue, orders, customers, low stock, recent orders
- Products: create / **edit** / delete, discount price, availability toggle
- Categories & home banners management
- Orders: view items & update status (pending → confirmed → out for delivery → delivered / cancelled)
- Customers list with order counts

---

## 🛠️ API Overview
All endpoints under `/api/v1`. Highlights:
- `POST /auth/signup`, `POST /auth/login`, `GET /auth/me`
- `GET /products`, `GET /categories`, `GET /banners`
- `GET|POST|PUT|DELETE /cart...`, `POST /orders/create`, `GET /orders/my`
- Admin: `GET /admin/dashboard`, `GET /admin/orders`, `PUT /admin/orders/{id}/status`, `GET /admin/products`, `GET /admin/customers`

Full interactive docs at `/docs` when the backend is running.

---

## 📝 Notes
- `backend/.env` (secrets) is git-ignored — never commit it. Use `backend/.env.example` as a template.
- The database is hosted on Neon (managed Postgres, SSL required).
