import logging
from api.models.project import Project
from api.repositories.json_repository import JsonRepository

logger = logging.getLogger(__name__)

class ProjectService:
    def __init__(self, repo: JsonRepository):
        self.repo = repo
        logger.info("ProjectService initialized with JsonRepository")

    async def get_all_projects(self) -> list[Project]:
        return await self.repo.get_all_projects()

    async def get_project_by_id(self, project_id: str) -> Project:
        project = await self.repo.get_project_by_id(project_id)
        if not project:
            raise ValueError("Project not found")
        return project
