from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException

from api.models.project import Project
from api.repositories.json_repository import JsonRepository
from api.services.project_service import ProjectService

router = APIRouter(prefix="/api/projects", tags=["Projects"])


def get_repo():
    return JsonRepository()


def get_project_service(repo: JsonRepository = Depends(get_repo)):
    return ProjectService(repo)


Service = Annotated[ProjectService, Depends(get_project_service)]


@router.get("/", response_model=list[Project])
async def list_projects(service: Service):
    """Fetch all projects from the static JSON store."""
    return await service.get_all_projects()


@router.get("/{project_id}", response_model=Project)
async def get_project(project_id: str, service: Service):
    """Fetch a single project by ID."""
    try:
        project = await service.get_project_by_id(project_id)
        return project
    except ValueError:
        raise HTTPException(status_code=404, detail="Project not found")
