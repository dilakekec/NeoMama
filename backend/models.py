from typing import Optional, List
from sqlmodel import Field, SQLModel

class BabyProfile(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    birth_date: str  
    feeding_preferences: Optional[str]
    allergies: Optional[str]
    notes: Optional[str]


class FeedingSchedule(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    baby_id: int = Field(foreign_key="babyprofile.id")
    feeding_time: str 
    feeding_type: str  # e.g., breast milk, formula, solid food
    amount: Optional[str]  # e.g., 4 oz, 1 cup  
    notes: Optional[str]
    
 
