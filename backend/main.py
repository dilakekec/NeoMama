from dotenv import load_dotenv
import os
from pydantic import BaseModel
import httpx
from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import SQLModel, Session, select
from typing import List
from models import FeedingSchedule, BabyProfile
import json
from database import engine, get_session

load_dotenv()
OPENROUTER_API_KEY = "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"
app = FastAPI(title="NeoMama API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str

@app.on_event("startup")
def on_startup():
    SQLModel.metadata.create_all(engine)

@app.post("/api/baby", response_model=BabyProfile)
def create_baby(profile: BabyProfile, session: Session = Depends(get_session)):
    session.add(profile)
    session.commit()
    session.refresh(profile)
    return profile

@app.get("/api/baby/{baby_id}", response_model=BabyProfile)
def get_baby(baby_id: int, session: Session = Depends(get_session)):
    baby = session.exec(select(BabyProfile).where(BabyProfile.id == baby_id)).first()
    if not baby:
        raise HTTPException(status_code=404, detail="Baby not found")
    return baby

@app.put("/api/baby/{baby_id}", response_model=BabyProfile)
def update_baby(baby_id: int, data: BabyProfile, session: Session = Depends(get_session)):
    baby = session.get(BabyProfile, baby_id)
    if not baby:
        raise HTTPException(status_code=404, detail="Baby not found")
    baby.name = data.name
    baby.birth_date = data.birth_date
    baby.feeding_preferences = data.feeding_preferences
    baby.allergies = data.allergies
    baby.notes = data.notes
    session.commit()
    session.refresh(baby)
    return baby 

@app.delete("/api/baby/{baby_id}", status_code=204)
def delete_baby(baby_id: int, session: Session = Depends(get_session)):
    baby = session.get(BabyProfile, baby_id)
    if not baby:
        raise HTTPException(status_code=404, detail="Baby not found")
    session.delete(baby)
    session.commit()

@app.post("/api/baby/{baby_id}/schedule", response_model=FeedingSchedule)
def create_schedule(baby_id: int, schedule: list[str], session: Session = Depends(get_session)):
    baby = session.get(BabyProfile, baby_id)
    if not baby:
        raise HTTPException(status_code=404, detail="Baby not found")
    sched = FeedingSchedule(baby_id=baby_id, times=json.dumps(schedule))
    session.add(sched)
    session.commit()
    session.refresh(sched)
    return sched

@app.get("/api/baby/{baby_id}/schedule", response_model=list[str])
def get_schedule(baby_id: int, session: Session = Depends(get_session)):
    sched = session.exec(select(FeedingSchedule).where(FeedingSchedule.baby_id == baby_id)).first()
    if not sched:
        return []
    return json.loads(sched.times)

@app.get("/api/babies", response_model=List[BabyProfile])
def get_all_babies(session: Session = Depends(get_session)):
    return session.exec(select(BabyProfile)).all()
    
@app.post("/api/chat")
async def chat_with_openrouter(payload: ChatRequest):
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
    }

    body = {
        "model":"openai/gpt-4o",
        "max_tokens": 500,
        "messages": [
            {"role": "user", "content": payload.message}
        ]
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(  
            "https://openrouter.ai/api/v1/chat/completions",
            headers=headers,
            json=body
        )
        result = response.json()
        print("API result:", result)

        if "choices" not in result:
            return {"error": result.get("error", "OpenRouter answer invalid.")}

    return {
        "reply": result["choices"][0]["message"]["content"]
    }