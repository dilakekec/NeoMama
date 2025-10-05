from typing import Optional
from sqlmodel import Field, SQLModel

class BabyProfile(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    birth_date: str  # ISO format (YYYY-MM-DD)
    feeding_preferences: Optional[str] = None
    allergies: Optional[str] = None
    notes: Optional[str] = None


class FeedingSchedule(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    baby_id: int = Field(foreign_key="babyprofile.id")
    times: str  # JSON string: ["08:00", "12:00", ...]