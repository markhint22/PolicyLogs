# Testing Infrastructure

This directory contains the testing infrastructure for the Policy Logs project, including integration tests, end-to-end tests, and testing utilities.

## Directory Structure

- `integration/` - Integration tests that test component interactions
- `e2e/` - End-to-end tests that test complete user workflows
- `utils/` - Testing utilities and helper functions
- `fixtures/` - Test data and fixtures
- `config/` - Testing configuration files

## Test Types

### Unit Tests
Unit tests are located within each component:
- Backend: `backend/*/tests/`
- Frontend: `web/src/**/*.test.ts`
- iOS: `ios/*Tests/`
- Android: `android/app/src/test/`

### Integration Tests
Integration tests verify that different components work together correctly:
- API integration tests
- Database integration tests
- Service integration tests

### End-to-End Tests
E2E tests simulate real user interactions across the entire application:
- Web application workflows
- Mobile application workflows
- Cross-platform compatibility tests

## Running Tests

### All Tests
```bash
./scripts/test.sh
```

### Backend Tests Only
```bash
cd backend
source venv/bin/activate
python manage.py test
```

### Frontend Tests Only
```bash
cd web
npm test
```

### Integration Tests
```bash
python -m pytest tests/integration/
```

### E2E Tests
```bash
python -m pytest tests/e2e/
```

## Test Configuration

### Environment Variables
Tests use separate environment configurations:
- `TEST_DATABASE_URL` - Test database connection
- `TEST_API_BASE_URL` - API base URL for testing
- `TEST_FRONTEND_URL` - Frontend URL for E2E tests

### Test Data
Test fixtures are located in `tests/fixtures/` and include:
- Sample users
- Sample policy logs
- Sample comments and tags

## Writing Tests

### Integration Test Example
```python
import pytest
from tests.utils.api_client import APIClient

@pytest.mark.integration
def test_policy_log_creation():
    client = APIClient()
    response = client.create_policy_log({
        'title': 'Test Policy',
        'description': 'Test Description'
    })
    assert response.status_code == 201
    assert 'id' in response.json()
```

### E2E Test Example
```python
import pytest
from selenium import webdriver
from tests.utils.web_driver import WebDriverManager

@pytest.mark.e2e
def test_user_login_workflow():
    driver = WebDriverManager().get_driver()
    # Test implementation
    driver.quit()
```

## Continuous Integration

Tests are automatically run in CI/CD pipeline:
- On pull requests
- Before deployments
- Nightly regression tests

## Test Coverage

Target coverage goals:
- Backend: >90%
- Frontend: >80%
- Integration: >70%
- E2E: Critical user paths

Generate coverage reports:
```bash
# Backend coverage
cd backend
coverage run --source='.' manage.py test
coverage html

# Frontend coverage
cd web
npm run test:coverage
```