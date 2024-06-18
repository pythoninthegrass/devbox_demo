import pytest
import sys
from pathlib import Path

# add top-level directory repo to the sys.path
# * controls for ./app/main.py imports
current_dir = Path(__file__).resolve().parent
project_root = current_dir.parent
sys.path.insert(0, str(project_root))

from app.main import app, db, Visitors


@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
        yield client


def test_home(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b'Visitor count:' in response.data


def test_meetup_redirect(client):
    response = client.get('/meetup')
    assert response.status_code == 301
    assert response.headers['Location'] == '/teatime'


def test_teatime(client):
    response = client.get('/teatime')
    assert response.status_code == 418
    assert b'Teatime' in response.data
