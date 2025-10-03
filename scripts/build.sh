#!/bin/bash

# Build script for all components of the Policy Logs project
# This script builds the web frontend, prepares the backend, and creates mobile app builds

set -e  # Exit on any error

echo "🚀 Building Policy Logs Project..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the project root
if [ ! -f "README.md" ] || [ ! -d "web" ] || [ ! -d "backend" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Build Web Frontend
print_status "Building web frontend..."
cd web
if [ ! -d "node_modules" ]; then
    print_status "Installing web dependencies..."
    npm install
fi

print_status "Building production web assets..."
npm run build

print_status "Web build completed ✅"
cd ..

# Prepare Backend
print_status "Preparing Django backend..."
cd backend

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_warning "Virtual environment not found. Creating one..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install/update dependencies
print_status "Installing backend dependencies..."
pip install -r requirements.txt

# Run Django checks
print_status "Running Django system checks..."
python manage.py check

# Collect static files
print_status "Collecting static files..."
python manage.py collectstatic --noinput

# Run migrations
print_status "Running database migrations..."
python manage.py migrate

print_status "Backend preparation completed ✅"
cd ..

# iOS Build (if Xcode is available)
if command -v xcodebuild &> /dev/null; then
    print_status "Building iOS app..."
    cd ios
    
    # Check if we have Package.swift
    if [ -f "Package.swift" ]; then
        print_status "Resolving iOS dependencies..."
        swift package resolve
    fi
    
    print_status "iOS dependencies resolved ✅"
    cd ..
else
    print_warning "Xcode not found. Skipping iOS build."
fi

# Android Build (if Gradle is available)
if [ -f "android/gradlew" ]; then
    print_status "Building Android app..."
    cd android
    
    print_status "Running Android build..."
    ./gradlew assembleDebug
    
    print_status "Android build completed ✅"
    cd ..
else
    print_warning "Android Gradle wrapper not found. Skipping Android build."
fi

print_status "🎉 All builds completed successfully!"
print_status "Built components:"
print_status "  - Web frontend (./web/dist)"
print_status "  - Backend static files collected"
print_status "  - Database migrations applied"
if command -v xcodebuild &> /dev/null; then
    print_status "  - iOS dependencies resolved"
fi
if [ -f "android/gradlew" ]; then
    print_status "  - Android APK (./android/app/build/outputs/apk/debug/)"
fi

echo ""
print_status "Next steps:"
print_status "  1. Run 'scripts/dev.sh' to start development servers"
print_status "  2. Run 'scripts/deploy.sh' to deploy to production"
print_status "  3. Check 'docs/' for detailed documentation"