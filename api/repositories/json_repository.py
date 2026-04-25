import json
import logging
from pathlib import Path
from api.models.project import Project
from api.config import settings

logger = logging.getLogger(__name__)

class JsonRepository:
    def __init__(self, data_path: str = settings.DATA_PATH):
        self.data_path = Path(data_path)
        self._ensure_data_exists()

    def _ensure_data_exists(self):
        """Ensures the data directory and file exist."""
        if not self.data_path.exists():
            logger.warning(f"Data file not found at {self.data_path}. Creating initial structure.")
            self.data_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.data_path, "w") as f:
                json.dump([], f)

    async def get_all_projects(self) -> list[Project]:
        """Fetch all projects from the JSON file."""
        logger.info(f"Loading projects from {self.data_path}")
        try:
            with open(self.data_path, "r") as f:
                data = json.load(f)
            return [Project(**item) for item in data]
        except Exception as e:
            logger.error(f"Failed to load projects: {e}")
            return []

    async def get_project_by_id(self, project_id: str) -> Project | None:
        """Fetch a single project by its ID."""
        projects = await self.get_all_projects()
        return next((p for p in projects if p.id == project_id), None)
