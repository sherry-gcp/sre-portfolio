import pytest
from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_read_main():
    """Test the root index page loads."""
    response = client.get("/")
    assert response.status_code == 200


def test_get_projects_list():
    """Test the API returns the list of projects."""
    response = client.get("/api/projects/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    # Check for one of your specific projects
    names = [p["name"] for p in data]
    assert "Farmers Fleet" in names


def test_custom_labels():
    """Test that custom labels are correctly returned."""
    response = client.get("/api/projects/")
    data = response.json()
    sql_project = next(p for p in data if p["id"] == "sql-data-warehouse")
    assert sql_project["live_demo_label"] == "Course Page"
    assert sql_project["documentation_url"] is not None


def test_project_not_found():
    """Test 404 for non-existent project."""
    response = client.get("/api/projects/non-existent-id")
    assert response.status_code == 404
