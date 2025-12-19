#!/usr/bin/env bash
set -e

PROJECT="ai-helpdesk"

mkdir -p "$PROJECT"/{app,app/services,app/routers,app/kb,tests}
# Make Python treat directories as packages
touch "$PROJECT/app/__init__.py"
touch "$PROJECT/app/routers/__init__.py"
touch "$PROJECT/app/services/__init__.py"

# -------------------------
# Dependencies
# -------------------------
cat > "$PROJECT/requirements.txt" <<'REQ'
fastapi
uvicorn
pydantic
python-dotenv
pytest
httpx
REQ

# -------------------------
# Environment template
# -------------------------
cat > "$PROJECT/.env.example" <<'ENV'
API_KEY=change-me
LLM_PROVIDER=mock
OPENAI_API_KEY=
MODEL_NAME=
ENV

# -------------------------
# App config
# -------------------------
cat > "$PROJECT/app/config.py" <<'PY'
from pydantic import BaseModel
from dotenv import load_dotenv
import os

load_dotenv()

class Settings(BaseModel):
    api_key: str = os.getenv("API_KEY", "change-me")
    llm_provider: str = os.getenv("LLM_PROVIDER", "mock")

settings = Settings()
PY

cat > "$PROJECT/app/security.py" <<'PY'
from fastapi import Header, HTTPException
from .config import settings

def require_api_key(x_api_key: str = Header(default="")):
    if x_api_key != settings.api_key:
        raise HTTPException(status_code=401, detail="Invalid API Key")
PY

cat > "$PROJECT/app/schemas.py" <<'PY'
from pydantic import BaseModel, Field
from typing import Optional, List

class TicketCreate(BaseModel):
    title: str
    user: str
    description: str

class TicketOut(BaseModel):
    id: int
    title: str
    user: str
    description: str
    status: str

class AISuggestRequest(BaseModel):
    ticket_id: int

class AISuggestResponse(BaseModel):
    ticket_id: int
    suggested_steps: List[str]
PY

# -------------------------
# In-memory ticket store
# -------------------------
cat > "$PROJECT/app/services/store.py" <<'PY'
class TicketStore:
    def __init__(self):
        self.tickets = {}
        self.counter = 1

    def create(self, title, user, description):
        ticket = {
            "id": self.counter,
            "title": title,
            "user": user,
            "description": description,
            "status": "open"
        }
        self.tickets[self.counter] = ticket
        self.counter += 1
        return ticket

    def get(self, ticket_id):
        return self.tickets.get(ticket_id)

store = TicketStore()
PY

# -------------------------
# AI mock service
# -------------------------
cat > "$PROJECT/app/services/ai.py" <<'PY'
def suggest_resolution(ticket):
    return {
        "ticket_id": ticket["id"],
        "suggested_steps": [
            "Confirm the exact error message.",
            "Check service status dashboards.",
            "Validate user credentials.",
            "Escalate if unresolved."
        ]
    }
PY

# -------------------------
# Routers
# -------------------------
cat > "$PROJECT/app/routers/tickets.py" <<'PY'
from fastapi import APIRouter, Depends, HTTPException
from ..schemas import TicketCreate
from ..services.store import store
from ..security import require_api_key

router = APIRouter(
    dependencies=[Depends(require_api_key)],
    tags=["tickets"]
)


@router.post("/tickets")
def create_ticket(payload: TicketCreate):
    return store.create(payload.title, payload.user, payload.description)

@router.get("/tickets/{ticket_id}")
def get_ticket(ticket_id: int):
    ticket = store.get(ticket_id)
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return ticket
PY

# -------------------------
# Main app
# -------------------------
cat > "$PROJECT/app/routers/ai.py" <<'PY'
from fastapi import APIRouter, Depends, HTTPException
from ..services.store import store
from ..services.ai import suggest_resolution
from ..security import require_api_key
from ..schemas import AISuggestRequest

router = APIRouter(dependencies=[Depends(require_api_key)])

@router.post("/ai/suggest")
def suggest(payload: AISuggestRequest):
    ticket = store.get(payload.ticket_id)
    if not ticket:
        raise HTTPException(status_code=404, detail="Ticket not found")
    return suggest_resolution(ticket)
PY


echo "✅ AI Help Desk scaffold created"
