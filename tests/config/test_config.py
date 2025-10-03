# Test configuration settings
import os

# Test database configuration
TEST_DATABASE_URL = os.getenv('TEST_DATABASE_URL', 'sqlite:///test_policy_logs.db')

# API configuration for testing
TEST_API_BASE_URL = os.getenv('TEST_API_BASE_URL', 'http://localhost:8000/api/')
TEST_FRONTEND_URL = os.getenv('TEST_FRONTEND_URL', 'http://localhost:3000')

# Authentication settings
TEST_TOKEN_EXPIRY = 3600  # 1 hour
TEST_SESSION_TIMEOUT = 1800  # 30 minutes

# Browser configuration for E2E tests
DEFAULT_BROWSER = os.getenv('TEST_BROWSER', 'chrome')
HEADLESS_BROWSER = os.getenv('HEADLESS', 'true').lower() == 'true'
BROWSER_TIMEOUT = int(os.getenv('BROWSER_TIMEOUT', '10'))

# Test execution settings
PARALLEL_WORKERS = int(os.getenv('PYTEST_WORKERS', '1'))
TEST_TIMEOUT = int(os.getenv('TEST_TIMEOUT', '300'))  # 5 minutes
RETRY_COUNT = int(os.getenv('TEST_RETRY_COUNT', '2'))

# Screenshots and artifacts
SCREENSHOT_ON_FAILURE = os.getenv('SCREENSHOT_ON_FAILURE', 'true').lower() == 'true'
ARTIFACTS_DIR = os.getenv('ARTIFACTS_DIR', 'tests/artifacts')

# Coverage settings
COVERAGE_THRESHOLD = float(os.getenv('COVERAGE_THRESHOLD', '80.0'))
COVERAGE_FAIL_UNDER = os.getenv('COVERAGE_FAIL_UNDER', 'false').lower() == 'true'

# Environment flags
CI_MODE = os.getenv('CI', 'false').lower() == 'true'
DEBUG_MODE = os.getenv('DEBUG', 'false').lower() == 'true'
VERBOSE_LOGGING = os.getenv('VERBOSE', 'false').lower() == 'true'