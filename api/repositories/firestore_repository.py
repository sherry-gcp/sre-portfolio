import os
from typing import Optional

from google.cloud import firestore_v1 as firestore

from api.models.project import Project

class FirestoreRepository:
    def __init__(self):
        # SRE Best Practice: Use Env Vars for Configuration
        project_id = os.getenv("GOOGLE_CLOUD_PROJECT", "sherrywelder")
        database_id = os.getenv("FIRESTORE_DATABASE_ID", "projects")
        
        self.db = firestore.AsyncClient(
            project=project_id,
            database=database_id
        )
        self.collection = self.db.collection(os.getenv("FIRESTORE_COLLECTION", "projects"))

    async def get_all_projects(self) -> list[Project]:
        docs = self.collection.stream()
        return [
            Project(id=doc.id, **{k: v for k, v in doc.to_dict().items() if k != "id"})
            async for doc in docs
        ]

    async def get_project_by_id(self, project_id: str) -> Optional[Project]:
        doc = await self.collection.document(project_id).get()
        if not doc.exists:
            return None
        data = doc.to_dict()
        # Prevent "multiple values for keyword argument 'id'"
        data.pop("id", None)
        return Project(id=doc.id, **data)

    # Should i add this create on repository or service?
    async def save_project(self, project: Project) -> Project:
        await self.collection.document(project.id).set(project.model_dump())
        return project

    async def delete_project_by_id(self, project_id: str) -> bool:
        doc = await self.collection.document(project_id).get()
        return bool(doc.exists) and await self.collection.document(project_id).delete()
