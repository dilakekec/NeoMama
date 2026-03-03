from __future__ import annotations

import os
from pathlib import Path
from typing import Optional, List

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from sqlmodel import SQLModel, Field, Session, create_engine, select

from openai import OpenAI


# --- ENV: backend/.env oku (mobil uygulama .env'inden ayır) ---
ENV_PATH = Path(__file__).resolve().parent / ".env"  # backend/.env
if ENV_PATH.exists():
    load_dotenv(dotenv_path=ENV_PATH, override=True)


# --- API ---
app = FastAPI(title="NeoMama API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # prod'da daraltırsın
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# --- DB ---
engine = create_engine("sqlite:///neomama.db", echo=False)

class Baby(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    birth_date: str  # "YYYY-MM-DD"
    feeding_preferences: Optional[str] = None
    allergies: Optional[str] = None
    notes: Optional[str] = None

class BabyCreate(SQLModel):
    name: str
    birth_date: str
    feeding_preferences: Optional[str] = None
    allergies: Optional[str] = None
    notes: Optional[str] = None

class BabyRead(SQLModel):
    id: int
    name: str
    birth_date: str
    feeding_preferences: Optional[str] = None
    allergies: Optional[str] = None
    notes: Optional[str] = None

@app.on_event("startup")
def on_startup():
    SQLModel.metadata.create_all(engine)

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/api/babies", response_model=List[BabyRead])
def list_babies():
    with Session(engine) as session:
        babies = session.exec(select(Baby).order_by(Baby.id.desc())).all()
        return babies

@app.post("/api/baby", response_model=BabyRead, status_code=201)
def create_baby(payload: BabyCreate):
    baby = Baby(**payload.model_dump())
    with Session(engine) as session:
        session.add(baby)
        session.commit()
        session.refresh(baby)
        return baby

@app.put("/api/baby/{baby_id}", response_model=BabyRead)
def update_baby(baby_id: int, payload: BabyCreate):
    with Session(engine) as session:
        baby = session.get(Baby, baby_id)
        if not baby:
            raise HTTPException(status_code=404, detail="Baby not found")

        data = payload.model_dump()
        baby.name = data["name"]
        baby.birth_date = data["birth_date"]
        baby.feeding_preferences = data.get("feeding_preferences")
        baby.allergies = data.get("allergies")
        baby.notes = data.get("notes")

        session.add(baby)
        session.commit()
        session.refresh(baby)
        return baby

@app.delete("/api/baby/{baby_id}", status_code=204)
def delete_baby(baby_id: int):
    with Session(engine) as session:
        baby = session.get(Baby, baby_id)
        if not baby:
            raise HTTPException(status_code=404, detail="Baby not found")
        session.delete(baby)
        session.commit()
        return


# --- LLM ---
class LLMRequest(BaseModel):
    text: str


@app.post("/api/llm")
async def llm_chat(req: LLMRequest):
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="OPENAI_API_KEY missing")

    # Modeli .env ile ayarlayın. Varsayılan: gpt-4.1
    model = os.getenv("OPENAI_MODEL", "gpt-4.1")
    prompt_id = os.getenv("OPENAI_PROMPT_ID")
    prompt_version = os.getenv("OPENAI_PROMPT_VERSION")
    prompt_variable = os.getenv("OPENAI_PROMPT_VARIABLE", "").strip()

    client = OpenAI(api_key=api_key)

    try:
        kwargs = {"model": model}

        if prompt_id:
            prompt_payload = {"id": prompt_id}
            if prompt_version:
                prompt_payload["version"] = prompt_version
            if prompt_variable:
                prompt_payload["variables"] = {prompt_variable: req.text}
            kwargs["prompt"] = prompt_payload

            # Prompt içinde değişken yoksa, kullanıcı mesajını ayrıca input olarak gönder.
            if not prompt_variable:
                kwargs["input"] = req.text
        else:
            kwargs["input"] = req.text

        resp = client.responses.create(**kwargs)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI request failed: {e}")

    text_out = getattr(resp, "output_text", None)
    if not text_out:
        text_out = _extract_output_text(resp)

    if not text_out:
        raise HTTPException(status_code=500, detail="OpenAI returned empty response")

    return {"text": text_out, "model": model}


def _extract_output_text(resp: object) -> str | None:
    output = getattr(resp, "output", None)
    if not isinstance(output, list):
        return None
    parts: list[str] = []
    for item in output:
        item_type = item.get("type") if isinstance(item, dict) else getattr(item, "type", None)
        if item_type != "message":
            continue
        content = item.get("content") if isinstance(item, dict) else getattr(item, "content", None)
        if not isinstance(content, list):
            continue
        for c in content:
            ctype = c.get("type") if isinstance(c, dict) else getattr(c, "type", None)
            if ctype not in ("output_text", "text"):
                continue
            text = c.get("text") if isinstance(c, dict) else getattr(c, "text", None)
            if text:
                parts.append(str(text))
    return "".join(parts).strip() if parts else None
