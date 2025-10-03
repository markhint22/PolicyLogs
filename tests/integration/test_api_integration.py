import pytest
import requests
from tests.utils.api_client import APIClient, create_test_user


class TestAPIIntegration:
    """Integration tests for API endpoints."""
    
    @pytest.fixture(scope='class')
    def api_client(self):
        """Create API client for tests."""
        return APIClient()
    
    @pytest.fixture(scope='class')
    def authenticated_client(self, api_client):
        """Create authenticated API client."""
        # Create test user
        try:
            create_test_user(api_client, 'integration_test_user')
        except Exception:
            pass  # User might already exist
        
        # Login
        api_client.login('integration_test_user', 'testpass123')
        return api_client
    
    @pytest.mark.integration
    def test_user_registration_and_login(self, api_client):
        """Test user registration and login flow."""
        # Register new user
        user_data = {
            'username': 'test_register_user',
            'email': 'test@example.com',
            'first_name': 'Test',
            'last_name': 'User',
            'password': 'testpass123',
            'password_confirm': 'testpass123'
        }
        
        response = api_client.register(user_data)
        assert response.status_code == 201
        
        user = response.json()
        assert user['username'] == 'test_register_user'
        assert user['email'] == 'test@example.com'
        
        # Login with new user
        login_response = api_client.login('test_register_user', 'testpass123')
        assert 'token' in login_response
        assert 'user' in login_response
    
    @pytest.mark.integration
    def test_policy_log_crud_operations(self, authenticated_client):
        """Test complete CRUD operations for policy logs."""
        # Create policy log
        log_data = {
            'title': 'Integration Test Policy',
            'description': 'This is a test policy log for integration testing',
            'status': 'pending'
        }
        
        create_response = authenticated_client.create_policy_log(log_data)
        assert create_response.status_code == 201
        
        created_log = create_response.json()
        assert created_log['title'] == log_data['title']
        assert created_log['description'] == log_data['description']
        assert 'id' in created_log
        
        log_id = created_log['id']
        
        # Read policy log
        get_response = authenticated_client.get_policy_log(log_id)
        assert get_response.status_code == 200
        
        retrieved_log = get_response.json()
        assert retrieved_log['id'] == log_id
        assert retrieved_log['title'] == log_data['title']
        
        # Update policy log
        update_data = {
            'title': 'Updated Integration Test Policy',
            'description': 'Updated description',
            'status': 'active'
        }
        
        update_response = authenticated_client.update_policy_log(log_id, update_data)
        assert update_response.status_code == 200
        
        updated_log = update_response.json()
        assert updated_log['title'] == update_data['title']
        assert updated_log['status'] == update_data['status']
        
        # Delete policy log
        delete_response = authenticated_client.delete_policy_log(log_id)
        assert delete_response.status_code == 204
        
        # Verify deletion
        get_deleted_response = authenticated_client.get_policy_log(log_id)
        assert get_deleted_response.status_code == 404
    
    @pytest.mark.integration
    def test_policy_log_comments(self, authenticated_client):
        """Test adding comments to policy logs."""
        # Create policy log
        log_data = {
            'title': 'Policy for Comments Test',
            'description': 'Testing comment functionality'
        }
        
        create_response = authenticated_client.create_policy_log(log_data)
        assert create_response.status_code == 201
        
        log_id = create_response.json()['id']
        
        # Add comment
        comment_content = 'This is a test comment'
        comment_response = authenticated_client.add_comment(log_id, comment_content)
        assert comment_response.status_code == 201
        
        comment = comment_response.json()
        assert comment['content'] == comment_content
        assert 'id' in comment
        assert 'author_name' in comment
        
        # Verify comment is associated with log
        log_response = authenticated_client.get_policy_log(log_id)
        log_with_comments = log_response.json()
        
        assert len(log_with_comments['comments']) == 1
        assert log_with_comments['comments'][0]['content'] == comment_content
        
        # Clean up
        authenticated_client.delete_policy_log(log_id)
    
    @pytest.mark.integration
    def test_policy_log_filtering_and_search(self, authenticated_client):
        """Test filtering and search functionality."""
        # Create multiple policy logs
        logs_data = [
            {'title': 'Security Policy Alpha', 'description': 'Security related policy', 'status': 'active'},
            {'title': 'Privacy Policy Beta', 'description': 'Privacy related policy', 'status': 'pending'},
            {'title': 'General Guidelines', 'description': 'General company guidelines', 'status': 'active'}
        ]
        
        created_log_ids = []
        for log_data in logs_data:
            response = authenticated_client.create_policy_log(log_data)
            assert response.status_code == 201
            created_log_ids.append(response.json()['id'])
        
        try:
            # Test search
            search_response = authenticated_client.get_policy_logs(search='Security')
            assert search_response.status_code == 200
            
            search_results = search_response.json()['results']
            assert len(search_results) >= 1
            assert any('Security' in log['title'] for log in search_results)
            
            # Test status filtering
            active_response = authenticated_client.get_policy_logs(status='active')
            assert active_response.status_code == 200
            
            active_results = active_response.json()['results']
            for log in active_results:
                if log['id'] in created_log_ids:
                    assert log['status'] == 'active'
            
        finally:
            # Clean up created logs
            for log_id in created_log_ids:
                authenticated_client.delete_policy_log(log_id)
    
    @pytest.mark.integration
    def test_authentication_required_endpoints(self, api_client):
        """Test that protected endpoints require authentication."""
        # Test creating policy log without authentication
        log_data = {'title': 'Test', 'description': 'Test'}
        response = api_client.create_policy_log(log_data)
        assert response.status_code == 401
        
        # Test accessing user's logs without authentication
        response = api_client.get_my_logs()
        assert response.status_code == 401
        
        # Test logout without authentication
        response = api_client.logout()
        assert response.status_code == 401
    
    @pytest.mark.integration
    def test_tags_functionality(self, authenticated_client):
        """Test tags creation and association with policy logs."""
        # Create tag
        tag_data = {
            'name': 'Integration Test Tag',
            'color': '#FF5733'
        }
        
        tag_response = authenticated_client.create_tag(tag_data)
        assert tag_response.status_code == 201
        
        tag = tag_response.json()
        assert tag['name'] == tag_data['name']
        assert tag['color'] == tag_data['color']
        tag_id = tag['id']
        
        # Create policy log with tag
        log_data = {
            'title': 'Tagged Policy Log',
            'description': 'Policy log with tags',
            'tag_ids': [tag_id]
        }
        
        log_response = authenticated_client.create_policy_log(log_data)
        assert log_response.status_code == 201
        
        created_log = log_response.json()
        assert len(created_log['tags']) == 1
        assert created_log['tags'][0]['id'] == tag_id
        
        # Clean up
        authenticated_client.delete_policy_log(created_log['id'])
        
        # Verify tags list includes our tag
        tags_response = authenticated_client.get_tags()
        assert tags_response.status_code == 200
        
        tags = tags_response.json()
        tag_names = [t['name'] for t in tags]
        assert tag_data['name'] in tag_names