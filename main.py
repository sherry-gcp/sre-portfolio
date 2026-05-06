import logging

from fastapi import Depends, FastAPI, Request, Response
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from api.config import settings
from api.logging_config import setup_gcp_logging
from api.routers.asset_router import router as asset_router
from api.routers.project_router import ProjectService, get_project_service
from api.routers.project_router import router as project_router

setup_gcp_logging()

logger = logging.getLogger(__name__)
logger.info("Portfolio API booting up...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="A stateless, high-performance SRE portfolio",
    docs_url=None,
    redoc_url=None,
    openapi_url=None,
)

app.include_router(project_router)
app.include_router(asset_router)


@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    """Empty response for favicon to prevent 404s."""
    return Response(status_code=204)


@app.get("/robots.txt", include_in_schema=False)
async def robots():
    """Serve robots.txt to discourage aggressive crawlers."""
    return FileResponse("web/robots.txt")


app.mount("/js", StaticFiles(directory="web/js", html=False), name="js")
app.mount("/css", StaticFiles(directory="web/css", html=False), name="css")
app.mount("/img", StaticFiles(directory="web/img", html=False), name="img")

templates = Jinja2Templates(directory="web/html")
HTML_CACHE_HEADERS = {"Cache-Control": "public, max-age=86400"}


@app.get("/")
@app.get("/index")
@app.api_route("/", methods=["GET", "HEAD"])
@app.api_route("/index", methods=["GET", "HEAD"])
async def root(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="index.html",
        headers=HTML_CACHE_HEADERS,
    )


@app.get("/projects")
async def projects_page(
    request: Request, service: ProjectService = Depends(get_project_service)
):
    projects = await service.get_all_projects()
    return templates.TemplateResponse(
        request=request,
        name="projects.html",
        context={"projects": projects},
        headers=HTML_CACHE_HEADERS,
    )


@app.get("/about")
async def about_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="about.html",
        headers=HTML_CACHE_HEADERS,
    )


@app.get("/connect")
async def connect_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="connect.html",
        headers=HTML_CACHE_HEADERS,
    )
