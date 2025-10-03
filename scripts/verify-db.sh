#!/bin/bash

# PostgreSQL Setup Verification Script for Policy Logs

echo "🔍 PostgreSQL Setup Verification"
echo "================================"

# Check if PostgreSQL is running
if brew services list | grep -q "postgresql.*started"; then
    echo "✅ PostgreSQL service is running"
else
    echo "❌ PostgreSQL service is not running"
    echo "Starting PostgreSQL..."
    brew services start postgresql@14
fi

# Check if database exists
if psql -lqt | cut -d \| -f 1 | grep -qw policy_logs; then
    echo "✅ Database 'policy_logs' exists"
else
    echo "❌ Database 'policy_logs' does not exist"
    echo "Creating database..."
    createdb policy_logs
fi

# Check database connection and tables
echo ""
echo "📊 Database Tables:"
psql -d policy_logs -c "\dt" 2>/dev/null | head -20

echo ""
echo "🔐 Admin User Status:"
cd /Users/mhintermeister/Library/CloudStorage/OneDrive-TeladocHealth/Documents/PolicyLogs/backend
source venv/bin/activate 2>/dev/null
python -c "
from django.contrib.auth.models import User
try:
    admin = User.objects.get(username='admin')
    print(f'✅ Admin user exists: {admin.username} ({admin.email})')
    print(f'   - Staff status: {admin.is_staff}')
    print(f'   - Superuser: {admin.is_superuser}')
except User.DoesNotExist:
    print('❌ Admin user does not exist')
" 2>/dev/null

echo ""
echo "🌐 Server Status:"
if curl -s http://localhost:8000/admin/ >/dev/null 2>&1; then
    echo "✅ Django server is accessible at http://localhost:8000"
    echo "   - Admin: http://localhost:8000/admin/ (admin/admin123)"
    echo "   - API: http://localhost:8000/api/"
else
    echo "❌ Django server is not running"
    echo "   Start with: cd backend && source venv/bin/activate && python manage.py runserver"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Django Admin: http://localhost:8000/admin/ (admin/admin123)"
echo "2. Start frontend: cd ../web && npm run dev"
echo "3. API Documentation: http://localhost:8000/api/"