"""Sample test data and fixtures for Policy Logs project."""

import datetime
from typing import Dict, List, Any


# Sample users for testing
SAMPLE_USERS = [
    {
        'username': 'testuser1',
        'email': 'testuser1@example.com',
        'first_name': 'Test',
        'last_name': 'User One',
        'password': 'testpass123'
    },
    {
        'username': 'testuser2',
        'email': 'testuser2@example.com',
        'first_name': 'Test',
        'last_name': 'User Two',
        'password': 'testpass123'
    },
    {
        'username': 'admin_user',
        'email': 'admin@example.com',
        'first_name': 'Admin',
        'last_name': 'User',
        'password': 'adminpass123',
        'is_staff': True,
        'is_superuser': True
    }
]

# Sample policy logs
SAMPLE_POLICY_LOGS = [
    {
        'title': 'Security Access Policy',
        'description': 'Policy regarding security access controls and user authentication procedures.',
        'status': 'active',
        'priority': 'high',
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    },
    {
        'title': 'Data Privacy Guidelines',
        'description': 'Comprehensive guidelines for handling and protecting user data privacy.',
        'status': 'pending',
        'priority': 'medium',
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    },
    {
        'title': 'Remote Work Policy',
        'description': 'Policy outlining requirements and guidelines for remote work arrangements.',
        'status': 'draft',
        'priority': 'low',
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    },
    {
        'title': 'Code Review Standards',
        'description': 'Standards and procedures for conducting code reviews in development projects.',
        'status': 'active',
        'priority': 'high',
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    },
    {
        'title': 'Emergency Response Protocol',
        'description': 'Protocol for responding to system emergencies and security incidents.',
        'status': 'active',
        'priority': 'critical',
        'created_at': datetime.datetime.now().isoformat(),
        'updated_at': datetime.datetime.now().isoformat()
    }
]

# Sample comments
SAMPLE_COMMENTS = [
    {
        'content': 'This policy looks comprehensive. I suggest adding more details about multi-factor authentication.',
        'created_at': datetime.datetime.now().isoformat()
    },
    {
        'content': 'We should consider the impact on user experience when implementing these security measures.',
        'created_at': datetime.datetime.now().isoformat()
    },
    {
        'content': 'The privacy guidelines need to be updated to comply with GDPR requirements.',
        'created_at': datetime.datetime.now().isoformat()
    },
    {
        'content': 'This policy has been reviewed and approved by the security team.',
        'created_at': datetime.datetime.now().isoformat()
    }
]

# Sample tags
SAMPLE_TAGS = [
    {
        'name': 'Security',
        'color': '#FF6B6B',
        'description': 'Security-related policies and procedures'
    },
    {
        'name': 'Privacy',
        'color': '#4ECDC4',
        'description': 'Data privacy and protection policies'
    },
    {
        'name': 'HR',
        'color': '#45B7D1',
        'description': 'Human resources policies'
    },
    {
        'name': 'Development',
        'color': '#96CEB4',
        'description': 'Development and coding standards'
    },
    {
        'name': 'Emergency',
        'color': '#FECA57',
        'description': 'Emergency procedures and protocols'
    },
    {
        'name': 'Compliance',
        'color': '#FF9FF3',
        'description': 'Regulatory compliance policies'
    }
]

# Sample API responses for mocking
SAMPLE_API_RESPONSES = {
    'login_success': {
        'token': 'sample_auth_token_12345',
        'user': {
            'id': 1,
            'username': 'testuser1',
            'email': 'testuser1@example.com',
            'first_name': 'Test',
            'last_name': 'User One'
        }
    },
    'policy_log_list': {
        'count': 3,
        'next': None,
        'previous': None,
        'results': SAMPLE_POLICY_LOGS[:3]
    },
    'policy_log_detail': SAMPLE_POLICY_LOGS[0],
    'tags_list': SAMPLE_TAGS,
    'error_unauthorized': {
        'detail': 'Authentication credentials were not provided.'
    },
    'error_not_found': {
        'detail': 'Not found.'
    },
    'error_validation': {
        'title': ['This field is required.'],
        'description': ['This field is required.']
    }
}


class TestDataGenerator:
    """Helper class for generating test data."""
    
    @staticmethod
    def create_user_data(username: str = None, **overrides) -> Dict[str, Any]:
        """Create user data with optional overrides."""
        base_data = {
            'username': username or f'testuser_{datetime.datetime.now().timestamp()}',
            'email': f'{username or "testuser"}@example.com',
            'first_name': 'Test',
            'last_name': 'User',
            'password': 'testpass123',
            'password_confirm': 'testpass123'
        }
        base_data.update(overrides)
        return base_data
    
    @staticmethod
    def create_policy_log_data(title: str = None, **overrides) -> Dict[str, Any]:
        """Create policy log data with optional overrides."""
        timestamp = datetime.datetime.now().timestamp()
        base_data = {
            'title': title or f'Test Policy {timestamp}',
            'description': f'Test policy description created at {timestamp}',
            'status': 'pending',
            'priority': 'medium'
        }
        base_data.update(overrides)
        return base_data
    
    @staticmethod
    def create_comment_data(content: str = None, **overrides) -> Dict[str, Any]:
        """Create comment data with optional overrides."""
        timestamp = datetime.datetime.now().timestamp()
        base_data = {
            'content': content or f'Test comment created at {timestamp}'
        }
        base_data.update(overrides)
        return base_data
    
    @staticmethod
    def create_tag_data(name: str = None, **overrides) -> Dict[str, Any]:
        """Create tag data with optional overrides."""
        timestamp = datetime.datetime.now().timestamp()
        base_data = {
            'name': name or f'TestTag{timestamp}',
            'color': '#FF5733',
            'description': f'Test tag created at {timestamp}'
        }
        base_data.update(overrides)
        return base_data
    
    @staticmethod
    def get_sample_users(count: int = None) -> List[Dict[str, Any]]:
        """Get sample users data."""
        if count is not None:
            return SAMPLE_USERS[:count]
        return SAMPLE_USERS.copy()
    
    @staticmethod
    def get_sample_policy_logs(count: int = None) -> List[Dict[str, Any]]:
        """Get sample policy logs data."""
        if count is not None:
            return SAMPLE_POLICY_LOGS[:count]
        return SAMPLE_POLICY_LOGS.copy()
    
    @staticmethod
    def get_sample_tags(count: int = None) -> List[Dict[str, Any]]:
        """Get sample tags data."""
        if count is not None:
            return SAMPLE_TAGS[:count]
        return SAMPLE_TAGS.copy()
    
    @staticmethod
    def get_sample_comments(count: int = None) -> List[Dict[str, Any]]:
        """Get sample comments data."""
        if count is not None:
            return SAMPLE_COMMENTS[:count]
        return SAMPLE_COMMENTS.copy()


def load_test_fixtures() -> Dict[str, Any]:
    """Load all test fixtures into a dictionary."""
    return {
        'users': SAMPLE_USERS,
        'policy_logs': SAMPLE_POLICY_LOGS,
        'comments': SAMPLE_COMMENTS,
        'tags': SAMPLE_TAGS,
        'api_responses': SAMPLE_API_RESPONSES
    }


def create_minimal_test_data() -> Dict[str, Any]:
    """Create minimal test data set for basic testing."""
    return {
        'user': TestDataGenerator.create_user_data('minimal_test_user'),
        'policy_log': TestDataGenerator.create_policy_log_data('Minimal Test Policy'),
        'comment': TestDataGenerator.create_comment_data('Minimal test comment'),
        'tag': TestDataGenerator.create_tag_data('MinimalTag')
    }