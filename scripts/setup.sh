#!/bin/bash

# Setup script for Policy Logs project
# This script sets up the entire development environment from scratch

set -e

echo "🚀 Policy Logs Project Setup"

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

# Check system requirements
check_requirements() {
    print_header "Checking System Requirements"
    
    # Check Python 3
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_status "Python 3 found: $PYTHON_VERSION"
    else
        print_error "Python 3 is required but not installed"
        print_error "Please install Python 3.9 or later"
        exit 1
    fi
    
    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_status "Node.js found: $NODE_VERSION"
    else
        print_error "Node.js is required but not installed"
        print_error "Please install Node.js 18 or later"
        exit 1
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_status "npm found: $NPM_VERSION"
    else
        print_error "npm is required but not installed"
        exit 1
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_status "Git found: $GIT_VERSION"
    else
        print_warning "Git not found - recommended for development"
    fi
    
    # Check optional tools
    if command -v xcodebuild &> /dev/null; then
        print_status "Xcode found - iOS development available"
    else
        print_warning "Xcode not found - iOS development not available"
    fi
    
    if command -v docker &> /dev/null; then
        print_status "Docker found - containerized development available"
    else
        print_warning "Docker not found - containerized deployment not available"
    fi
    
    print_status "Requirements check completed ✅"
}

# Setup backend
setup_backend() {
    print_header "Setting Up Django Backend"
    
    cd backend
    
    # Create virtual environment
    print_status "Creating Python virtual environment..."
    python3 -m venv venv
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    print_status "Upgrading pip..."
    pip install --upgrade pip
    
    # Install dependencies
    print_status "Installing Python dependencies..."
    
    # Try installing with updated pip and better compatibility
    pip install --upgrade setuptools wheel
    
    # Install dependencies with fallback for corporate environments
    if ! pip install -r requirements.txt; then
        print_warning "Standard installation failed, trying with no-cache and --user fallback..."
        pip install --no-cache-dir -r requirements.txt || {
            print_error "Failed to install Python dependencies"
            print_error "This might be due to corporate proxy/artifactory configuration"
            print_error "Please try manually: cd backend && source venv/bin/activate && pip install -r requirements.txt"
            exit 1
        }
    fi
    
    # Create .env file from example
    if [ ! -f ".env" ]; then
        print_status "Creating environment configuration..."
        cp .env.example .env
        print_warning "Please edit backend/.env with your configuration"
    fi
    
    # Create necessary directories
    mkdir -p logs media staticfiles backups
    
    # Run initial migrations
    print_status "Setting up database..."
    if python manage.py migrate; then
        print_status "Database migrations completed successfully"
        
        # Create superuser (interactive)
        print_status "Creating superuser account..."
        echo "Please create an admin account:"
        if ! python manage.py createsuperuser; then
            print_warning "Superuser creation skipped or failed - you can create one later with: python manage.py createsuperuser"
        fi
    else
        print_warning "Database migrations failed - this might be due to missing database setup"
        print_warning "You can run migrations later with: python manage.py migrate"
    fi
    
    # Load initial data (if available)
    if [ -f "fixtures/initial_data.json" ]; then
        print_status "Loading initial data..."
        python manage.py loaddata fixtures/initial_data.json
    fi
    
    cd ..
    print_status "Backend setup completed ✅"
}

# Setup frontend
setup_frontend() {
    print_header "Setting Up React Frontend"
    
    cd web
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    # Create environment file
    if [ ! -f ".env.local" ]; then
        print_status "Creating frontend environment file..."
        cat > .env.local << EOF
VITE_API_URL=http://localhost:8000/api
EOF
        print_status "Created .env.local with default configuration"
    fi
    
    # Build once to verify everything works
    print_status "Running initial build to verify setup..."
    npm run build
    
    cd ..
    print_status "Frontend setup completed ✅"
}

# Setup mobile development
setup_mobile() {
    print_header "Setting Up Mobile Development"
    
    # iOS setup
    if command -v xcodebuild &> /dev/null; then
        print_status "Setting up iOS development..."
        cd ios
        
        if [ -f "Package.swift" ]; then
            print_status "iOS dependencies will be resolved when you open the project in Xcode"
            print_warning "Skipping swift package resolve to avoid corporate artifactory conflicts"
        fi
        
        print_status "iOS setup completed ✅"
        print_status "To develop iOS app: Open ios/PolicyLogs.xcodeproj in Xcode"
        cd ..
    else
        print_warning "Skipping iOS setup - Xcode not available"
    fi
    
    # Android setup
    print_status "Setting up Android development..."
    cd android
    
    # Make gradlew executable
    chmod +x gradlew
    
    # Create local.properties if it doesn't exist
    if [ ! -f "local.properties" ]; then
        # Try to detect Android SDK
        if [ -d "$HOME/Library/Android/sdk" ]; then
            echo "sdk.dir=$HOME/Library/Android/sdk" > local.properties
            print_status "Android SDK configured"
        elif [ -d "$ANDROID_HOME" ]; then
            echo "sdk.dir=$ANDROID_HOME" > local.properties
            print_status "Android SDK configured from ANDROID_HOME"
        else
            print_warning "Android SDK not found. Please set up Android Studio and SDK"
        fi
    fi
    
    print_status "Android setup completed ✅"
    print_status "To develop Android app: Open android/ folder in Android Studio"
    cd ..
}

# Setup development tools
setup_dev_tools() {
    print_header "Setting Up Development Tools"
    
    # Make scripts executable
    chmod +x scripts/*.sh
    print_status "Made scripts executable"
    
    # Create VS Code settings (if VS Code is being used)
    if command -v code &> /dev/null; then
        print_status "Setting up VS Code configuration..."
        mkdir -p .vscode
        
        cat > .vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "./backend/venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "eslint.workingDirectories": ["web"],
    "typescript.preferences.includePackageJsonAutoImports": "on"
}
EOF
        
        cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Django",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/backend/manage.py",
            "args": ["runserver"],
            "django": true,
            "cwd": "${workspaceFolder}/backend"
        }
    ]
}
EOF
        
        print_status "VS Code configuration created"
    fi
    
    # Setup Git hooks (if Git is available)
    if command -v git &> /dev/null && [ -d ".git" ]; then
        print_status "Setting up Git hooks..."
        
        # Pre-commit hook
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Run linting before commit
echo "Running pre-commit checks..."

# Check Python code with flake8 (if available)
if command -v flake8 &> /dev/null; then
    flake8 backend/ || exit 1
fi

# Check JavaScript/TypeScript code with ESLint (if available)
cd web
if command -v npx &> /dev/null; then
    npx eslint src/ --ext .ts,.tsx || exit 1
fi
cd ..

echo "Pre-commit checks passed!"
EOF
        chmod +x .git/hooks/pre-commit
        print_status "Git hooks configured"
    fi
    
    print_status "Development tools setup completed ✅"
}

# Main setup flow
main() {
    print_status "Welcome to Policy Logs project setup!"
    print_status "This script will set up the complete development environment."
    
    # Confirm before proceeding
    read -p "Do you want to continue? (y/N): " confirm
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
        print_status "Setup cancelled"
        exit 0
    fi
    
    # Run setup steps
    check_requirements
    setup_backend
    setup_frontend
    setup_mobile
    setup_dev_tools
    
    print_header "Setup Complete!"
    print_status "🎉 Policy Logs development environment is ready!"
    print_status ""
    print_status "Next steps:"
    print_status "1. Edit backend/.env with your configuration"
    print_status "2. Run './scripts/dev.sh' to start development servers"
    print_status "3. Open http://localhost:3000 for the web app"
    print_status "4. Open http://localhost:8000/admin for Django admin"
    print_status ""
    print_status "Mobile development:"
    print_status "- iOS: Open ios/PolicyLogs.xcodeproj in Xcode"
    print_status "- Android: Open android/ folder in Android Studio"
    print_status ""
    print_status "Documentation: ./docs/README.md"
    print_status "Happy coding! 🚀"
}

# Run main function
main