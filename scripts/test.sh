#!/bin/bash

# Test execution script for Policy Logs project
# Usage: ./scripts/test.sh [test_type] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE=${1:-"all"}
HEADLESS=${HEADLESS:-true}
BROWSER=${BROWSER:-chrome}
COVERAGE=${COVERAGE:-true}
PARALLEL=${PARALLEL:-false}
VERBOSE=${VERBOSE:-false}

# Directories
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
WEB_DIR="$PROJECT_ROOT/web"
TESTS_DIR="$PROJECT_ROOT/tests"

echo -e "${BLUE}Policy Logs Test Runner${NC}"
echo "================================"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to setup test environment
setup_test_env() {
    print_status "Setting up test environment..."
    
    # Create artifacts directory
    mkdir -p "$TESTS_DIR/artifacts"
    mkdir -p "$TESTS_DIR/reports"
    mkdir -p "$TESTS_DIR/screenshots"
    
    # Export environment variables
    export DJANGO_SETTINGS_MODULE="policy_logs.settings_test"
    export TEST_MODE=true
    export HEADLESS="$HEADLESS"
    export BROWSER="$BROWSER"
    
    print_status "Test environment setup complete"
}

# Function to install test dependencies
install_test_deps() {
    print_status "Installing test dependencies..."
    
    # Install Python test dependencies
    if [ -f "$TESTS_DIR/requirements.txt" ]; then
        pip install -r "$TESTS_DIR/requirements.txt"
    fi
    
    # Install Node.js test dependencies if needed
    if [ -f "$WEB_DIR/package.json" ]; then
        cd "$WEB_DIR"
        npm install
        cd "$PROJECT_ROOT"
    fi
}

# Function to run backend tests
run_backend_tests() {
    print_status "Running backend tests..."
    
    cd "$BACKEND_DIR"
    
    # Activate virtual environment if it exists
    if [ -d "venv" ]; then
        source venv/bin/activate
    fi
    
    # Run Django tests
    python manage.py test --settings=policy_logs.settings_test
    
    print_status "Backend tests completed"
}

# Function to run frontend tests
run_frontend_tests() {
    print_status "Running frontend tests..."
    
    cd "$WEB_DIR"
    
    if [ "$COVERAGE" = "true" ]; then
        npm run test:coverage
    else
        npm test
    fi
    
    print_status "Frontend tests completed"
}

# Function to run integration tests
run_integration_tests() {
    print_status "Running integration tests..."
    
    cd "$PROJECT_ROOT"
    
    local pytest_args=""
    
    if [ "$VERBOSE" = "true" ]; then
        pytest_args="$pytest_args -v"
    fi
    
    if [ "$COVERAGE" = "true" ]; then
        pytest_args="$pytest_args --cov=backend --cov-report=html:$TESTS_DIR/reports/coverage"
    fi
    
    if [ "$PARALLEL" = "true" ]; then
        pytest_args="$pytest_args -n auto"
    fi
    
    pytest -m integration $pytest_args "$TESTS_DIR/integration/"
    
    print_status "Integration tests completed"
}

# Function to run E2E tests
run_e2e_tests() {
    print_status "Running E2E tests..."
    
    cd "$PROJECT_ROOT"
    
    # Start backend server in background if not running
    if ! curl -s http://localhost:8000/api/health/ > /dev/null 2>&1; then
        print_status "Starting backend server..."
        cd "$BACKEND_DIR"
        source venv/bin/activate 2>/dev/null || true
        python manage.py runserver 8000 > /dev/null 2>&1 &
        BACKEND_PID=$!
        cd "$PROJECT_ROOT"
        
        # Wait for backend to start
        sleep 5
    fi
    
    # Start frontend server in background if not running
    if ! curl -s http://localhost:3000 > /dev/null 2>&1; then
        print_status "Starting frontend server..."
        cd "$WEB_DIR"
        npm start > /dev/null 2>&1 &
        FRONTEND_PID=$!
        cd "$PROJECT_ROOT"
        
        # Wait for frontend to start
        sleep 10
    fi
    
    # Run E2E tests
    local pytest_args=""
    
    if [ "$VERBOSE" = "true" ]; then
        pytest_args="$pytest_args -v"
    fi
    
    pytest -m e2e $pytest_args "$TESTS_DIR/e2e/"
    
    # Cleanup background processes
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    
    print_status "E2E tests completed"
}

# Function to run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    
    # Backend unit tests
    print_status "Running backend unit tests..."
    run_backend_tests
    
    # Frontend unit tests
    print_status "Running frontend unit tests..."
    run_frontend_tests
    
    print_status "Unit tests completed"
}

# Function to run all tests
run_all_tests() {
    print_status "Running all tests..."
    
    run_unit_tests
    run_integration_tests
    run_e2e_tests
    
    print_status "All tests completed successfully!"
}

# Function to run smoke tests
run_smoke_tests() {
    print_status "Running smoke tests..."
    
    cd "$PROJECT_ROOT"
    pytest -m smoke "$TESTS_DIR/"
    
    print_status "Smoke tests completed"
}

# Function to generate test report
generate_report() {
    print_status "Generating test report..."
    
    cd "$PROJECT_ROOT"
    
    # Generate HTML report if coverage was collected
    if [ -f ".coverage" ]; then
        coverage html -d "$TESTS_DIR/reports/coverage"
        print_status "Coverage report generated: $TESTS_DIR/reports/coverage/index.html"
    fi
    
    print_status "Test report generation completed"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [test_type] [options]"
    echo ""
    echo "Test types:"
    echo "  all         Run all tests (default)"
    echo "  unit        Run unit tests only"
    echo "  integration Run integration tests only"
    echo "  e2e         Run E2E tests only"
    echo "  smoke       Run smoke tests only"
    echo "  backend     Run backend tests only"
    echo "  frontend    Run frontend tests only"
    echo ""
    echo "Environment variables:"
    echo "  HEADLESS=true|false    Run browser tests in headless mode (default: true)"
    echo "  BROWSER=chrome|firefox Browser to use for E2E tests (default: chrome)"
    echo "  COVERAGE=true|false    Generate coverage reports (default: true)"
    echo "  PARALLEL=true|false    Run tests in parallel (default: false)"
    echo "  VERBOSE=true|false     Verbose output (default: false)"
    echo ""
    echo "Examples:"
    echo "  $0 all"
    echo "  $0 unit"
    echo "  HEADLESS=false $0 e2e"
    echo "  COVERAGE=true PARALLEL=true $0 integration"
}

# Main execution
main() {
    # Check for help flag
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    fi
    
    # Setup test environment
    setup_test_env
    
    # Install dependencies if needed
    if [ "$2" = "--install-deps" ]; then
        install_test_deps
    fi
    
    # Run tests based on type
    case "$TEST_TYPE" in
        "all")
            run_all_tests
            ;;
        "unit")
            run_unit_tests
            ;;
        "integration")
            run_integration_tests
            ;;
        "e2e")
            run_e2e_tests
            ;;
        "smoke")
            run_smoke_tests
            ;;
        "backend")
            run_backend_tests
            ;;
        "frontend")
            run_frontend_tests
            ;;
        *)
            print_error "Unknown test type: $TEST_TYPE"
            show_usage
            exit 1
            ;;
    esac
    
    # Generate reports
    if [ "$COVERAGE" = "true" ]; then
        generate_report
    fi
    
    print_status "Test execution completed successfully!"
}

# Check if required tools are available
check_requirements() {
    local missing_tools=()
    
    if ! command_exists python; then
        missing_tools+=("python")
    fi
    
    if ! command_exists pip; then
        missing_tools+=("pip")
    fi
    
    if [ ! -z "$missing_tools" ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install the missing tools and try again."
        exit 1
    fi
}

# Run requirement checks
check_requirements

# Execute main function
main "$@"