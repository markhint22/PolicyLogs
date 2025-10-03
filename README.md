# Policy Logs - Full Stack Application

A comprehensive policy management system with web frontend, mobile applications, and REST API backend.

## 🏗️ Architecture Overview

This is a monorepo containing multiple applications and services:

- **Web Frontend** (`web/`) - React + TypeScript + Vite
- **Backend API** (`backend/`) - Django + Django REST Framework  
- **iOS App** (`ios/`) - SwiftUI with native iOS features
- **Android App** (`android/`) - Kotlin + Jetpack Compose
- **Documentation** (`docs/`) - Project documentation and API specs
- **Scripts** (`scripts/`) - Development and deployment automation
- **Tests** (`tests/`) - Integration and end-to-end testing

## 🚀 Quick Start

### Prerequisites

- **Python 3.9+** with pip
- **Node.js 18+** with npm
- **Xcode 14+** (for iOS development)
- **Android Studio** with SDK 33+ (for Android development)
- **Git** for version control

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd PolicyLogs
   ```

2. **Run automated setup**
   ```bash
   ./scripts/setup.sh
   ```

3. **Start development servers**
   ```bash
   ./scripts/dev.sh
   ```

4. **Access the applications**
   - Web: http://localhost:3000
   - API: http://localhost:8000
   - Admin: http://localhost:8000/admin

## 📱 Applications

### Web Frontend
Modern React application with TypeScript, providing a responsive web interface for policy management.

**Features:**
- User authentication and authorization
- Policy logs CRUD operations
- Real-time search and filtering
- Responsive design for all devices
- Modern UI with React Router

**Tech Stack:**
- React 18 + TypeScript
- Vite for build tooling
- Axios for API communication
- React Router for navigation

### Backend API
RESTful API built with Django, providing comprehensive policy management capabilities.

**Features:**
- User authentication with tokens
- Policy logs with comments and tags
- Advanced search and filtering
- Admin interface for management
- PostgreSQL database support

**Tech Stack:**
- Django 4.2 + Python
- Django REST Framework
- PostgreSQL database
- Celery for background tasks

### iOS Application
Native iOS app built with SwiftUI, offering full policy management on mobile devices.

**Features:**
- Native iOS UI with SwiftUI
- Secure keychain storage
- Offline capability
- Push notifications ready
- iOS-specific integrations

**Tech Stack:**
- SwiftUI + Swift
- Alamofire for networking
- Keychain services
- iOS 16+ compatibility

### Android Application
Modern Android app using Jetpack Compose with material design.

**Features:**
- Material Design 3 UI
- Hilt dependency injection
- Offline-first architecture
- Dark mode support
- Android 13+ compatibility

**Tech Stack:**
- Kotlin + Jetpack Compose
- Hilt for dependency injection
- Retrofit for networking
- DataStore for preferences

## 🛠️ Development

### Running Individual Components

**Backend Only:**
```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

**Frontend Only:**
```bash
cd web
npm start
```

**iOS Development:**
```bash
cd ios
open PolicyLogs.xcodeproj
# Build and run in Xcode
```

**Android Development:**
```bash
cd android
./gradlew assembleDebug
# Or open in Android Studio
```

### Environment Configuration

Create `.env` files in each component directory:

**Backend** (`backend/.env`):
```env
SECRET_KEY=your-secret-key
DATABASE_URL=postgresql://user:pass@localhost/policy_logs
DEBUG=True
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

**Frontend** (`web/.env`):
```env
VITE_API_BASE_URL=http://localhost:8000/api
VITE_APP_TITLE=Policy Logs
```

### Database Setup

**PostgreSQL (Recommended):**
```bash
# Install PostgreSQL
brew install postgresql  # macOS
sudo apt install postgresql  # Ubuntu

# Create database
createdb policy_logs

# Run migrations
cd backend
python manage.py migrate
python manage.py createsuperuser
```

**SQLite (Development):**
```bash
cd backend
python manage.py migrate
python manage.py createsuperuser
```

## 🧪 Testing

### Run All Tests
```bash
./scripts/test.sh
```

### Run Specific Test Types
```bash
# Unit tests only
./scripts/test.sh unit

# Integration tests
./scripts/test.sh integration

# E2E tests
./scripts/test.sh e2e

# Backend tests only
./scripts/test.sh backend

# Frontend tests only  
./scripts/test.sh frontend
```

### Test Configuration
- **Integration Tests:** Test API endpoints and database interactions
- **E2E Tests:** Test complete user workflows with Selenium
- **Unit Tests:** Component and function level testing
- **Coverage Reports:** Generated in `tests/reports/coverage/`

## 📦 Building & Deployment

### Build All Components
```bash
./scripts/build.sh
```

### Deploy to Production
```bash
./scripts/deploy.sh production
```

### Build Individual Components
```bash
# Build web frontend
cd web && npm run build

# Build iOS app
cd ios && xcodebuild -scheme PolicyLogs archive

# Build Android APK
cd android && ./gradlew assembleRelease

# Collect Django static files
cd backend && python manage.py collectstatic
```

## 📚 API Documentation

### Authentication
```bash
# Login
POST /api/auth/login/
{
  "username": "user@example.com",
  "password": "password"
}

# Response
{
  "token": "auth_token_here",
  "user": {
    "id": 1,
    "username": "user@example.com"
  }
}
```

### Policy Logs
```bash
# List policy logs
GET /api/policy-logs/

# Create policy log
POST /api/policy-logs/
{
  "title": "New Policy",
  "description": "Policy description",
  "status": "pending"
}

# Get specific log
GET /api/policy-logs/1/

# Update policy log  
PUT /api/policy-logs/1/

# Delete policy log
DELETE /api/policy-logs/1/
```

### Advanced Features
```bash
# Add comment
POST /api/policy-logs/1/add_comment/
{
  "content": "This is a comment"
}

# Search logs
GET /api/policy-logs/?search=security

# Filter by status
GET /api/policy-logs/?status=active

# Get user's logs
GET /api/policy-logs/my_logs/
```

Full API documentation available at: http://localhost:8000/api/docs/

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Run tests**
   ```bash
   ./scripts/test.sh
   ```
5. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
6. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Open a Pull Request**

### Code Style
- **Python:** Follow PEP 8, use Black formatter
- **TypeScript:** Use Prettier, ESLint configuration
- **Swift:** Follow Swift style guide
- **Kotlin:** Follow Kotlin coding conventions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation:** [docs/README.md](docs/README.md)
- **API Reference:** [docs/api/README.md](docs/api/README.md)
- **Issues:** Open a GitHub issue
- **Discussions:** Use GitHub Discussions for questions

## 🔮 Roadmap

- [ ] **Real-time Updates** - WebSocket support for live updates
- [ ] **Advanced Analytics** - Policy usage analytics and reporting
- [ ] **Multi-tenant Support** - Organization-level policy management  
- [ ] **Plugin System** - Extensible plugin architecture
- [ ] **Advanced Search** - Elasticsearch integration
- [ ] **Mobile Offline Sync** - Enhanced offline capabilities
- [ ] **Workflow Engine** - Automated policy approval workflows
- [ ] **Integration APIs** - Third-party service integrations

## 📊 Project Stats

- **Languages:** TypeScript, Python, Swift, Kotlin
- **Components:** 4 applications + shared infrastructure
- **Test Coverage:** Target >80% across all components
- **Documentation:** Comprehensive API and user documentation
- **Platform Support:** Web, iOS 16+, Android 13+

---

**Built with ❤️ for comprehensive policy management**