from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class ProjectBase(BaseModel):
    """Core model for a project."""

    name: str
    statement: str
    stack: list[str] = Field(default_factory=list)
    github_url: Optional[str] = None
    live_url: Optional[str] = None
    is_published: bool = True


class Project(ProjectBase):
    """Model for a project with all details."""

    id: str
    created_at: datetime = Field(default_factory=datetime.utcnow)


class ProjectCreate(ProjectBase):
    """Model for creating a new project."""

    pass


class ProjectUpdate(BaseModel):
    """Model for partially updating an existing project."""

    name: Optional[str] = None
    statement: Optional[str] = None
    stack: Optional[list[str]] = None
    github_url: Optional[str] = None
    live_url: Optional[str] = None
    is_published: Optional[bool] = None
