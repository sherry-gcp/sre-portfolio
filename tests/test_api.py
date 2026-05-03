import json
from pathlib import Path
import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)

# Load the source of truth data once for the tests
DATA_FILE = Path("api/data/projects.json")
with open(DATA_FILE, "r") as f:
    PROJECTS_DATA = json.load(f)


def test_read_main():
    """Test the root index page loads successfully."""
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]


def test_get_projects_list():
    """Test the API returns the complete list of projects accurately."""
    response = client.get("/api/projects")
    assert response.status_code == 200
    data = response.json()
    
    assert isinstance(data, list)
    assert len(data) == len(PROJECTS_DATA)
    
    # Verify that the IDs match the source of truth without hardcoding names
    api_ids = {p["id"] for p in data}
    file_ids = {p["id"] for p in PROJECTS_DATA}
    assert api_ids == file_ids


def test_project_schema_and_labels():
    """Test that all returned projects have valid structures and data types."""
    response = client.get("/api/projects")
    data = response.json()
    
    for project in data:
        assert "id" in project
        assert "name" in project
        assert isinstance(project["stack"], list)
        
        # Test optional label fields for correct type if they exist
        if "live_demo_label" in project and project["live_demo_label"] is not None:
            assert isinstance(project["live_demo_label"], str)
            
        if "documentation_label" in project and project["documentation_label"] is not None:
            assert isinstance(project["documentation_label"], str)


def test_get_single_project_valid():
    """Test retrieving a specific project dynamically by ID."""
    if not PROJECTS_DATA:
        pytest.skip("No projects available to test")
        
    test_project = PROJECTS_DATA[0]
    response = client.get(f"/api/projects/{test_project['id']}")
    
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == test_project["id"]
    assert data["name"] == test_project["name"]


def test_project_not_found():
    """Test 404 response for a guaranteed non-existent project."""
    response = client.get("/api/projects/non-existent-id-12345")
    assert response.status_code == 404
