from typing import Annotated

from fastapi import APIRouter, Depends, Header, HTTPException

from api.models.project import Project, ProjectCreate, ProjectUpdate
from api.repositories.firestore_repository import FirestoreRepository
from api.services.project_service import ProjectService

router = APIRouter(prefix="/api", tags=["Projects"])


def get_repo():
    return FirestoreRepository()


def get_project_service(repo: FirestoreRepository = Depends(get_repo)):
    return ProjectService(repo)


Service = Annotated[ProjectService, Depends(get_project_service)]


@router.post("/", response_model=Project, dependencies=[Admin])
async def create_project(project: ProjectCreate, service: Service):
    """Create a new project."""
    return await service.create_project(project)


@router.get("/", response_model=list[Project])
async def list_projects(service: Service):
    """Get all projects."""
    return await service.get_all_projects()


@router.get("/{project_id}", response_model=Project)
async def get_project(project_id: str, service: Service):
    """Get a project by its ID."""
    try:
        project = await service.get_project_by_id(project_id)
        return project
    except ValueError:
        raise HTTPException(status_code=404, detail="Project not found")


@router.patch("/{project_id}", response_model=Project, dependencies=[Admin])
async def update_project(project_id: str, project: ProjectUpdate, service: Service):
    """Update an existing project."""
    try:
        updated_project = await service.update_project(project_id, project)
        return updated_project
    except ValueError:
        raise HTTPException(status_code=404, detail="Project not found")


@router.delete("/{project_id}", dependencies=[Admin])
async def delete_project(project_id: str, service: Service):
    """Delete a project by its ID."""
    deleted = await service.delete_project_by_id(project_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Project not found")
    return {"message": "Project deleted successfully"}
