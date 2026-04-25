from pydantic import BaseModel, Field

class Project(BaseModel):
    """Project model for the static portfolio."""
    id: str
    name: str
    statement: str
    stack: list[str] = Field(default_factory=list)
    github_url: str | None = None
    live_demo_url: str | None = None
    live_demo_label: str | None = None
    documentation_url: str | None = None
    documentation_label: str | None = None

