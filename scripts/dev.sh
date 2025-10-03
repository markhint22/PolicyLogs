#!/bin/bash

# Development environment setup and start script
# This script sets up and starts all development servers

set -e

echo "🚀 Starting Policy Logs Development Environment..."

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

# Check if we're in the project root
if [ ! -f "README.md" ] || [ ! -d "web" ] || [ ! -d "backend" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Function to check if port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to start backend
start_backend() {
    print_header "Backend Setup"
    
    # Check PostgreSQL service
    if ! brew services list | grep -q "postgresql.*started"; then
        print_status "Starting PostgreSQL service..."
        brew services start postgresql@14
        sleep 2
    fi
    
    # Check if database exists
    if ! psql -lqt | cut -d \| -f 1 | grep -qw policy_logs; then
        print_status "Creating policy_logs database..."
        createdb policy_logs
    fi
    
    cd backend
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        print_status "Creating .env file..."
        cp .env.example .env
        print_warning "Please edit .env file with your configuration"
    fi
    
    # Run migrations
    print_status "Running database migrations..."
    python manage.py migrate
    
    # Check if superuser exists, if not prompt to create one
    if ! python manage.py shell -c "from django.contrib.auth.models import User; print('exists' if User.objects.filter(is_superuser=True).exists() else 'none')" | grep -q "exists"; then
        print_warning "No superuser found. You can create one later with: python manage.py createsuperuser"
    fi
    
    # Check if backend port is available
    if check_port 8000; then
        print_warning "Port 8000 is already in use. Backend might already be running."
    fi
    
    print_status "Starting Django development server on port 8000..."
    python manage.py runserver &
    BACKEND_PID=$!
    
    cd ..
}

# Function to start frontend
start_frontend() {
    print_header "Frontend Setup"
    cd web
    
    # Install dependencies
    if [ ! -d "node_modules" ]; then
        print_status "Installing Node.js dependencies..."
        npm install
    fi
    
    # Check if frontend port is available
    if check_port 3000; then
        print_warning "Port 3000 is already in use. Frontend might already be running."
    fi
    
    print_status "Starting React development server on port 3000..."
    npm run dev &
    FRONTEND_PID=$!
    
    cd ..
}

# Function to setup mobile development
setup_mobile() {
    print_header "Mobile Development Setup"
    
    # iOS setup
    if command -v xcodebuild &> /dev/null; then
        print_status "Xcode found - iOS development ready"
        print_status "To run iOS app: Open ios/PolicyLogs.xcodeproj in Xcode"
    else
        print_warning "Xcode not found - iOS development not available"
    fi
    
    # Android setup
    if [ -f "android/gradlew" ]; then
        print_status "Gradle wrapper found - Android development ready"
        print_status "To run Android app: Open android/ folder in Android Studio"
        
        cd android
        # Make gradlew executable
        chmod +x gradlew
        cd ..
    else
        print_warning "Android Gradle wrapper not found"
    fi
}

# Cleanup function
cleanup() {
    print_header "Stopping Development Servers"
    
    if [ ! -z "$BACKEND_PID" ]; then
        print_status "Stopping backend server (PID: $BACKEND_PID)"
        kill $BACKEND_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$FRONTEND_PID" ]; then
        print_status "Stopping frontend server (PID: $FRONTEND_PID)"
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    
    print_status "Development environment stopped"
}

# Set trap for cleanup on script exit
trap cleanup EXIT INT TERM

# Main execution
print_status "Checking system requirements..."

# Check Python
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is required but not installed"
    exit 1
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is required but not installed"
    exit 1
fi

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm is required but not installed"
    exit 1
fi

print_status "All requirements met ✅"

# Start services
start_backend
sleep 2  # Give backend time to start

start_frontend
sleep 2  # Give frontend time to start

setup_mobile

print_header "Development Environment Ready!"
print_status "🌐 Frontend: http://localhost:3000"
print_status "🔧 Backend API: http://localhost:8000/api/"
print_status "👨‍💼 Admin Panel: http://localhost:8000/admin/"
print_status ""
print_status "📱 Mobile Development:"
print_status "  - iOS: Open ios/PolicyLogs.xcodeproj in Xcode"
print_status "  - Android: Open android/ folder in Android Studio"
print_status ""
print_status "Press Ctrl+C to stop all servers"

# Wait for user interrupt
wait