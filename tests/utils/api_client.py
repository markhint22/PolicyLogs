import requests
import json
from typing import Dict, Any, Optional
from urllib.parse import urljoin


class APIClient:
    """HTTP client for testing API endpoints."""
    
    def __init__(self, base_url: str = "http://localhost:8000/api/", token: Optional[str] = None):
        self.base_url = base_url
        self.session = requests.Session()
        
        if token:
            self.session.headers.update({
                'Authorization': f'Token {token}'
            })
        
        self.session.headers.update({
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        })
    
    def _make_request(self, method: str, endpoint: str, **kwargs) -> requests.Response:
        """Make HTTP request to API endpoint."""
        url = urljoin(self.base_url, endpoint.lstrip('/'))
        
        if 'json' in kwargs:
            kwargs['data'] = json.dumps(kwargs.pop('json'))
        
        response = self.session.request(method, url, **kwargs)
        return response
    
    def get(self, endpoint: str, **kwargs) -> requests.Response:
        """Make GET request."""
        return self._make_request('GET', endpoint, **kwargs)
    
    def post(self, endpoint: str, **kwargs) -> requests.Response:
        """Make POST request."""
        return self._make_request('POST', endpoint, **kwargs)
    
    def put(self, endpoint: str, **kwargs) -> requests.Response:
        """Make PUT request."""
        return self._make_request('PUT', endpoint, **kwargs)
    
    def patch(self, endpoint: str, **kwargs) -> requests.Response:
        """Make PATCH request."""
        return self._make_request('PATCH', endpoint, **kwargs)
    
    def delete(self, endpoint: str, **kwargs) -> requests.Response:
        """Make DELETE request."""
        return self._make_request('DELETE', endpoint, **kwargs)
    
    # Authentication methods
    def login(self, username: str, password: str) -> Dict[str, Any]:
        """Login and get authentication token."""
        response = self.post('auth/login/', json={
            'username': username,
            'password': password
        })
        
        if response.status_code == 200:
            data = response.json()
            token = data.get('token')
            if token:
                self.session.headers.update({
                    'Authorization': f'Token {token}'
                })
            return data
        else:
            raise Exception(f'Login failed: {response.status_code} - {response.text}')
    
    def logout(self) -> requests.Response:
        """Logout current user."""
        return self.post('auth/logout/')
    
    def register(self, user_data: Dict[str, Any]) -> requests.Response:
        """Register new user."""
        return self.post('auth/register/', json=user_data)
    
    # Policy logs methods
    def get_policy_logs(self, **params) -> requests.Response:
        """Get list of policy logs."""
        return self.get('policy-logs/', params=params)
    
    def get_policy_log(self, log_id: int) -> requests.Response:
        """Get specific policy log."""
        return self.get(f'policy-logs/{log_id}/')
    
    def create_policy_log(self, log_data: Dict[str, Any]) -> requests.Response:
        """Create new policy log."""
        return self.post('policy-logs/', json=log_data)
    
    def update_policy_log(self, log_id: int, log_data: Dict[str, Any]) -> requests.Response:
        """Update policy log."""
        return self.put(f'policy-logs/{log_id}/', json=log_data)
    
    def delete_policy_log(self, log_id: int) -> requests.Response:
        """Delete policy log."""
        return self.delete(f'policy-logs/{log_id}/')
    
    def add_comment(self, log_id: int, content: str) -> requests.Response:
        """Add comment to policy log."""
        return self.post(f'policy-logs/{log_id}/add_comment/', json={
            'content': content
        })
    
    def get_my_logs(self) -> requests.Response:
        """Get current user's logs."""
        return self.get('policy-logs/my_logs/')
    
    # Tags methods
    def get_tags(self) -> requests.Response:
        """Get list of tags."""
        return self.get('tags/')
    
    def create_tag(self, tag_data: Dict[str, Any]) -> requests.Response:
        """Create new tag."""
        return self.post('tags/', json=tag_data)


class AuthenticatedAPIClient(APIClient):
    """API client that automatically authenticates with test user."""
    
    def __init__(self, username: str = "testuser", password: str = "testpass123", **kwargs):
        super().__init__(**kwargs)
        self.login(username, password)


def create_test_user(client: APIClient, username: str = "testuser") -> Dict[str, Any]:
    """Create a test user for testing purposes."""
    user_data = {
        'username': username,
        'email': f'{username}@example.com',
        'first_name': 'Test',
        'last_name': 'User',
        'password': 'testpass123',
        'password_confirm': 'testpass123'
    }
    
    response = client.register(user_data)
    
    if response.status_code == 201:
        return response.json()
    else:
        raise Exception(f'Failed to create test user: {response.status_code} - {response.text}')