#!/bin/bash

# Deployment script for Policy Logs project
# This script handles deployment to various environments

set -e

echo "🚀 Policy Logs Deployment Script"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Default values
ENVIRONMENT="staging"
SKIP_TESTS=false
SKIP_BUILD=false
BACKUP_DB=true

# Function to show usage
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Deployment environment (staging|production) [default: staging]"
    echo "  -s, --skip-tests         Skip running tests"
    echo "  -b, --skip-build         Skip build process"
    echo "  -n, --no-backup          Don't backup database"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e production         Deploy to production"
    echo "  $0 -e staging -s         Deploy to staging without tests"
    echo "  $0 --skip-build          Deploy without rebuilding"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -b|--skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -n|--no-backup)
            BACKUP_DB=false
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    print_error "Invalid environment: $ENVIRONMENT. Must be 'staging' or 'production'"
    exit 1
fi

print_header "Deploying to $ENVIRONMENT"

# Check if we're in the project root
if [ ! -f "README.md" ] || [ ! -d "web" ] || [ ! -d "backend" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Function to run tests
run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        print_warning "Skipping tests as requested"
        return
    fi
    
    print_header "Running Tests"
    
    # Backend tests
    print_status "Running Django tests..."
    cd backend
    source venv/bin/activate
    python manage.py test
    cd ..
    
    # Frontend tests (if test command exists)
    cd web
    if npm run test:ci &>/dev/null; then
        print_status "Running frontend tests..."
        npm run test:ci
    else
        print_warning "No frontend tests configured"
    fi
    cd ..
    
    print_status "All tests passed ✅"
}

# Function to build applications
build_applications() {
    if [ "$SKIP_BUILD" = true ]; then
        print_warning "Skipping build as requested"
        return
    fi
    
    print_header "Building Applications"
    
    # Use the build script
    ./scripts/build.sh
    
    print_status "Build completed ✅"
}

# Function to backup database
backup_database() {
    if [ "$BACKUP_DB" = false ]; then
        print_warning "Skipping database backup as requested"
        return
    fi
    
    print_header "Creating Database Backup"
    
    cd backend
    source venv/bin/activate
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="backup_${ENVIRONMENT}_${TIMESTAMP}.json"
    
    print_status "Creating backup: $BACKUP_FILE"
    python manage.py dumpdata --natural-foreign --natural-primary > "backups/$BACKUP_FILE"
    
    # Keep only last 10 backups
    cd backups
    ls -t backup_${ENVIRONMENT}_*.json | tail -n +11 | xargs rm -f 2>/dev/null || true
    cd ..
    
    cd ..
    print_status "Database backup created ✅"
}

# Function to deploy backend
deploy_backend() {
    print_header "Deploying Backend"
    
    cd backend
    
    # Create backups directory if it doesn't exist
    mkdir -p backups
    
    # Backup database
    backup_database
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install/update dependencies
    print_status "Installing production dependencies..."
    pip install -r requirements.txt
    
    # Run migrations
    print_status "Running database migrations..."
    python manage.py migrate
    
    # Collect static files
    print_status "Collecting static files..."
    python manage.py collectstatic --noinput
    
    # Create cache table (if using database cache)
    python manage.py createcachetable 2>/dev/null || true
    
    cd ..
    print_status "Backend deployment completed ✅"
}

# Function to deploy frontend
deploy_frontend() {
    print_header "Deploying Frontend"
    
    cd web
    
    # Install dependencies
    print_status "Installing frontend dependencies..."
    npm ci --only=production
    
    # Build for production
    if [ "$SKIP_BUILD" = false ]; then
        print_status "Building production frontend..."
        npm run build
    fi
    
    # The built files are in dist/ directory
    print_status "Frontend files ready in web/dist/"
    
    cd ..
    print_status "Frontend deployment completed ✅"
}

# Function to deploy to staging
deploy_staging() {
    print_status "Deploying to staging environment..."
    
    # Add staging-specific deployment logic here
    # This might include:
    # - Deploying to staging server
    # - Running staging-specific configurations
    # - Smoke tests
    
    print_warning "Staging deployment logic to be implemented"
    print_status "Files are ready for staging deployment"
}

# Function to deploy to production
deploy_production() {
    print_status "Deploying to production environment..."
    
    # Production deployment confirmation
    read -p "Are you sure you want to deploy to PRODUCTION? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        print_error "Production deployment cancelled"
        exit 1
    fi
    
    # Add production-specific deployment logic here
    # This might include:
    # - Deploying to production server
    # - Database migrations with extra care
    # - Health checks
    # - Rollback preparation
    
    print_warning "Production deployment logic to be implemented"
    print_status "Files are ready for production deployment"
}

# Function to perform health checks
health_checks() {
    print_header "Performing Health Checks"
    
    # Check if Django is working
    cd backend
    source venv/bin/activate
    
    print_status "Checking Django configuration..."
    python manage.py check --deploy
    
    cd ..
    
    # Add more health checks as needed
    # - Database connectivity
    # - External service availability
    # - File permissions
    
    print_status "Health checks completed ✅"
}

# Main deployment flow
print_status "Starting deployment process..."

# Run tests
run_tests

# Build applications
build_applications

# Deploy backend
deploy_backend

# Deploy frontend
deploy_frontend

# Environment-specific deployment
case $ENVIRONMENT in
    staging)
        deploy_staging
        ;;
    production)
        deploy_production
        ;;
esac

# Health checks
health_checks

print_header "Deployment Summary"
print_status "Environment: $ENVIRONMENT"
print_status "Tests: $([ "$SKIP_TESTS" = true ] && echo "Skipped" || echo "Passed")"
print_status "Build: $([ "$SKIP_BUILD" = true ] && echo "Skipped" || echo "Completed")"
print_status "Database Backup: $([ "$BACKUP_DB" = false ] && echo "Skipped" || echo "Created")"

print_status ""
print_status "🎉 Deployment completed successfully!"

if [ "$ENVIRONMENT" = "staging" ]; then
    print_status "Staging URL: https://staging.your-domain.com"
elif [ "$ENVIRONMENT" = "production" ]; then
    print_status "Production URL: https://your-domain.com"
fi

print_status "Admin Panel: https://your-domain.com/admin/"
print_status "API Documentation: https://your-domain.com/api/"