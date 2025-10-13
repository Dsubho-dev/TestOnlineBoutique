# conftest.py
import pytest
import yaml
import json
from pathlib import Path
import requests


@pytest.fixture(scope="session")
def endpoints():
    """Load service endpoints from YAML config."""
    config_path = Path(__file__).parent / "endpoints.yaml"
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


@pytest.fixture(scope="session")
def user_data():
    """Load user test data from JSON file."""
    data_path = Path(__file__).parent / "testdata" / "user_data.json"
    with open(data_path, "r") as f:
        return json.load(f)


@pytest.fixture(scope="session")
def check_services_health(endpoints):
    """Check that all key services are up before tests start."""
    for name, url in endpoints.items():
        try:
            resp = requests.get(url, timeout=5)
            print(f"[HEALTH] {name}: {resp.status_code}")
        except Exception as e:
            print(f"[WARN] {name} not reachable: {e}")
    yield
