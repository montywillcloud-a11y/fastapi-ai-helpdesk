# AI Help Desk API

## ✅ Status: Fully Functional API

This project is implemented and runnable locally. It includes:
- Ticket creation and retrieval
- API key–protected endpoints
- AI-based troubleshooting suggestions
- Interactive Swagger (OpenAPI) documentation

---

## 📘 API Documentation (Swagger)

Once running, the API exposes interactive documentation:

http://127.0.0.1:8000/docs

### Endpoints Demonstrated
- POST /tickets
- GET /tickets/{id}
- POST /ai/suggest
- GET /health

---

## 🧠 How It Works

- Tickets are stored in-memory (easily swappable for a database)
- Requests require an `X-API-Key` header for authentication
- AI suggestions are generated through a dedicated service layer
- Architecture is modular and designed for future production expansion

---

## ✨ Features

- Ticket CRUD API
- Knowledge Base (KB) ingestion from files
- AI “resolution suggestion” endpoint (mock provider by default)
- Simple API key authentication
- Clean, extensible architecture suitable for production use

---

## 📁 Folder Structure

ai-helpdesk/
├── app/
│ ├── main.py
│ ├── config.py
│ ├── security.py
│ ├── schemas.py
│ ├── kb/
│ ├── routers/
│ └── services/
├── tests/
├── requirements.txt
├── .env.example
└── README.md


---

## 🚀 Running Locally

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .\.venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn app.main:app --reload

Then visit:
http://127.0.0.1:8000/docs

## 📌 Resume Highlights

- Built a FastAPI-based backend service with secure API key authentication
- Implemented RESTful endpoints for ticket management and AI-driven suggestions
- Designed modular service architecture aligned with production best practices
- Documented and validated API functionality using Swagger (OpenAPI)
