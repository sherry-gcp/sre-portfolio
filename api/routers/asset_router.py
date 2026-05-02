from typing import Annotated

from fastapi import APIRouter, Depends

from api.services.asset_service import AssetService

router = APIRouter(prefix="/api/assets", tags=["Assets"])


def get_asset_service():
    return AssetService()


@router.get("")
async def get_assets(service: Annotated[AssetService, Depends(get_asset_service)]):
    """Returns the dynamic URLs for the primary portfolio assets."""
    return {
        "portrait": service.get_asset_url("portrait.png"),
        "resume": service.get_asset_url("resume.pdf"),
        "all_files": service.list_assets(),
    }
