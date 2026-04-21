import logging
from collections.abc import AsyncGenerator
from typing import Annotated

from fastapi import Depends

from api.models.project import Project, ProjectCreate, ProjectUpdate
from api.repositories.firestore_repository import FirestoreRepository

logger = logging.getLogger(__name__)


class ProjectService:
    def __init__(self, repo: FirestoreRepository):
        self.repo = repo
        logger.info("ProjectService initialized with FirestoreRepository")

    async def create_project(self, project_in: ProjectCreate) -> Project:
        """Create new project."""
        logger.info(f"Creating new project.")
        slug = project_in.name.lower().replace(" ", "-")
        full_project = Project(id=slug, **project_in.model_dump())
        return await self.repo.save_project(full_project)

    async def get_all_projects(self) -> list[Project]:
        """Fetch all projects from the database."""
        logger.info("Fetching all projects from database")
        return await self.repo.get_all_projects()

    async def get_project_by_id(self, project_id: str) -> Project:
        """Fetch a single project by its ID."""
        logger.info(f"Fetching project with ID: {project_id}")
        project = await self.repo.get_project_by_id(project_id)
        if not project:
            logger.warning(f"Project with ID {project_id} not found")
            raise ValueError("Project not found")
        logger.info(f"Project with ID {project_id} retrieved successfully")
        return project

    async def delete_project_by_id(self, project_id: str) -> bool:
        """Delete a project by its ID."""
        logger.info(f"Deleting project with ID: {project_id}")
        return await self.repo.delete_project_by_id(project_id)

    async def update_project(
        self, project_id: str, project_in: ProjectUpdate
    ) -> Project:
        """Update an existing project partially."""
        logger.info(f"Updating project with ID: {project_id}")
        existing_project = await self.repo.get_project_by_id(project_id)
        if not existing_project:
            logger.warning(f"Project with ID {project_id} not found for update")
            raise ValueError("Project not found")

        # Create a dictionary of update data (only fields that were set in the request)
        update_data = project_in.model_dump(exclude_unset=True)

        # Apply updates to the existing project
        project_dict = existing_project.model_dump()
        project_dict.update(update_data)

        # Create the updated Project model
        updated_project = Project(**project_dict)
        return await self.repo.save_project(updated_project)
