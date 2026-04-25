import logging
from fastapi import FastAPI, Request
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from api.logging_config import setup_gcp_logging
from api.routers.project_router import router as project_router
from api.config import settings

setup_gcp_logging()

logger = logging.getLogger(__name__)
logger.info("Portfolio API booting up...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="A stateless, high-performance SRE portfolio",
)

app.include_router(project_router)

templates = Jinja2Templates(directory="web/html")
CACHE_HEADERS = {"Cache-Control": "public, max-age=86400"}

@app.get("/")
@app.get("/index.html")
async def root(request: Request):
    return templates.TemplateResponse(
        request=request, name="index.html", headers=CACHE_HEADERS
    )
@app.get("/projects.html")
async def projects_page(request: Request):
    return templates.TemplateResponse(
        request=request, name="projects.html", headers=CACHE_HEADERS
    )
@app.get("/about.html")
async def about_page(request: Request):
    return templates.TemplateResponse(
        request=request, name="about.html", headers=CACHE_HEADERS
    )
@app.get("/connect.html")
async def connect_page(request: Request):
    return templates.TemplateResponse(
        request=request, name="connect.html", headers=CACHE_HEADERS
    )
app.mount("/js", StaticFiles(directory="web/js"), name="js")
app.mount("/css", StaticFiles(directory="web/css"), name="css")