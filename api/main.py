import logging
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from google.cloud import firestore_v1 as firestore

from api.logging_config import setup_gcp_logging
from api.routers.project_router import router as project_router

# Load environment variables
load_dotenv()

# Initialize structured JSON logging for GCP
setup_gcp_logging()

logger = logging.getLogger(__name__)
logger.info("Portfolio API booting up...")


db_client = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global db_client

    db_client = firestore.AsyncClient()
    logger.info("Firestore AsyncClient initialized")
    yield
    await db_client.close()
    logger.info("Firestore AsyncClient closed")


app = FastAPI(
    title="gcp portfolio  api",
    description="A simple landing page for my projects",
    lifespan=lifespan,
)


app.include_router(project_router)


@app.get("/")
async def root():
    return FileResponse("web/index.html")


app.mount("/static", StaticFiles(directory="web/static"), name="static")
