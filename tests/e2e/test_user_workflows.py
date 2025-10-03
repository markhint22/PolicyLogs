import pytest
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from tests.utils.web_driver import web_driver_session, PageHelper
from tests.utils.api_client import APIClient, create_test_user


class TestUserWorkflows:
    """End-to-end tests for complete user workflows."""
    
    @pytest.fixture(scope='class')
    def test_user_credentials(self):
        """Create test user for E2E tests."""
        api_client = APIClient()
        
        username = 'e2e_test_user'
        password = 'testpass123'
        
        try:
            create_test_user(api_client, username)
        except Exception:
            pass  # User might already exist
        
        return {'username': username, 'password': password}
    
    @pytest.mark.e2e
    def test_complete_user_journey(self, test_user_credentials):
        """Test complete user journey from login to logout."""
        with web_driver_session(headless=True) as page:
            # 1. Navigate to application
            page.navigate_to()
            
            # 2. Login
            page.login(
                test_user_credentials['username'], 
                test_user_credentials['password']
            )
            
            # 3. Verify successful login
            assert page.is_logged_in()
            
            # 4. Navigate to policy logs
            page.click_button((By.LINK_TEXT, 'Logs'))
            page.wait_for_element((By.CLASS_NAME, 'logs-list'))
            
            # 5. Create new policy log
            page.click_button((By.CLASS_NAME, 'add-log-button'))
            page.wait_for_element((By.NAME, 'title'))
            
            page.fill_form_field((By.NAME, 'title'), 'E2E Test Policy')
            page.fill_form_field((By.NAME, 'description'), 'This policy was created during E2E testing')
            
            page.click_button((By.TYPE, 'submit'))
            
            # 6. Verify policy log was created
            page.wait_for_text((By.CLASS_NAME, 'success-message'), 'Policy log created successfully')
            
            # 7. View policy log details
            page.click_button((By.LINK_TEXT, 'E2E Test Policy'))
            page.wait_for_element((By.CLASS_NAME, 'log-detail'))
            
            # 8. Add comment
            page.fill_form_field((By.NAME, 'comment'), 'This is an E2E test comment')
            page.click_button((By.CLASS_NAME, 'add-comment-button'))
            
            page.wait_for_text((By.CLASS_NAME, 'comment-content'), 'This is an E2E test comment')
            
            # 9. Navigate back to logs list
            page.click_button((By.CLASS_NAME, 'back-button'))
            page.wait_for_element((By.CLASS_NAME, 'logs-list'))
            
            # 10. Search for created policy
            search_input = page.wait_for_element((By.NAME, 'search'))
            search_input.clear()
            search_input.send_keys('E2E Test')
            
            page.wait_for_element((By.PARTIAL_LINK_TEXT, 'E2E Test Policy'))
            
            # 11. Logout
            page.logout()
            
            # 12. Verify logout
            assert not page.is_logged_in()
    
    @pytest.mark.e2e
    def test_user_registration_flow(self):
        """Test new user registration workflow."""
        with web_driver_session(headless=True) as page:
            # 1. Navigate to registration page
            page.navigate_to('/register')
            
            # 2. Fill registration form
            unique_username = f'e2e_new_user_{int(time.time())}'
            
            page.fill_form_field((By.NAME, 'username'), unique_username)
            page.fill_form_field((By.NAME, 'email'), f'{unique_username}@example.com')
            page.fill_form_field((By.NAME, 'firstName'), 'E2E')
            page.fill_form_field((By.NAME, 'lastName'), 'User')
            page.fill_form_field((By.NAME, 'password'), 'testpass123')
            page.fill_form_field((By.NAME, 'confirmPassword'), 'testpass123')
            
            # 3. Submit registration
            page.click_button((By.TYPE, 'submit'))
            
            # 4. Verify successful registration and automatic login
            page.wait_for_element((By.CLASS_NAME, 'dashboard'), timeout=15)
            assert page.is_logged_in()
            
            # 5. Logout
            page.logout()
    
    @pytest.mark.e2e
    def test_invalid_login_attempt(self):
        """Test handling of invalid login credentials."""
        with web_driver_session(headless=True) as page:
            # 1. Navigate to login page
            page.navigate_to('/login')
            
            # 2. Enter invalid credentials
            page.fill_form_field((By.NAME, 'username'), 'invalid_user')
            page.fill_form_field((By.NAME, 'password'), 'invalid_password')
            
            # 3. Submit form
            page.click_button((By.TYPE, 'submit'))
            
            # 4. Verify error message appears
            page.wait_for_element((By.CLASS_NAME, 'error-message'))
            error_message = page.driver.find_element(By.CLASS_NAME, 'error-message')
            assert 'Invalid credentials' in error_message.text or 'Login failed' in error_message.text
            
            # 5. Verify still on login page
            assert not page.is_logged_in()
    
    @pytest.mark.e2e
    def test_responsive_design(self, test_user_credentials):
        """Test application responsiveness on different screen sizes."""
        with web_driver_session(headless=True) as page:
            # Test mobile viewport
            page.driver.set_window_size(375, 667)  # iPhone SE size
            
            page.navigate_to()
            page.login(
                test_user_credentials['username'], 
                test_user_credentials['password']
            )
            
            # Verify mobile navigation works
            page.wait_for_element((By.CLASS_NAME, 'mobile-menu-toggle'))
            page.click_button((By.CLASS_NAME, 'mobile-menu-toggle'))
            page.wait_for_element((By.CLASS_NAME, 'mobile-nav-menu'))
            
            # Test tablet viewport
            page.driver.set_window_size(768, 1024)  # iPad size
            page.navigate_to('/logs')
            page.wait_for_element((By.CLASS_NAME, 'logs-list'))
            
            # Test desktop viewport
            page.driver.set_window_size(1920, 1080)  # Desktop size
            page.navigate_to('/logs')
            page.wait_for_element((By.CLASS_NAME, 'logs-list'))
            
            page.logout()
    
    @pytest.mark.e2e
    def test_accessibility_features(self, test_user_credentials):
        """Test basic accessibility features."""
        with web_driver_session(headless=True) as page:
            page.navigate_to()
            
            # Check for accessibility attributes
            username_input = page.wait_for_element((By.NAME, 'username'))
            assert username_input.get_attribute('aria-label') or username_input.get_attribute('placeholder')
            
            password_input = page.driver.find_element(By.NAME, 'password')
            assert password_input.get_attribute('type') == 'password'
            
            # Test keyboard navigation
            from selenium.webdriver.common.keys import Keys
            
            username_input.send_keys(Keys.TAB)
            active_element = page.driver.switch_to.active_element
            assert active_element.get_attribute('name') == 'password'
            
            # Test form submission with keyboard
            page.fill_form_field((By.NAME, 'username'), test_user_credentials['username'])
            page.fill_form_field((By.NAME, 'password'), test_user_credentials['password'])
            
            password_input = page.driver.find_element(By.NAME, 'password')
            password_input.send_keys(Keys.RETURN)
            
            # Verify login succeeded
            page.wait_for_element((By.CLASS_NAME, 'dashboard'), timeout=15)
            assert page.is_logged_in()
            
            page.logout()
    
    @pytest.mark.e2e
    @pytest.mark.slow
    def test_performance_and_loading(self, test_user_credentials):
        """Test application performance and loading times."""
        import time
        
        with web_driver_session(headless=True) as page:
            # Measure page load time
            start_time = time.time()
            page.navigate_to()
            page.wait_for_element((By.NAME, 'username'))
            load_time = time.time() - start_time
            
            # Assert reasonable load time (adjust threshold as needed)
            assert load_time < 5.0, f'Page load time too slow: {load_time}s'
            
            # Test login performance
            start_time = time.time()
            page.login(
                test_user_credentials['username'], 
                test_user_credentials['password']
            )
            login_time = time.time() - start_time
            
            assert login_time < 10.0, f'Login time too slow: {login_time}s'
            
            # Test navigation performance
            start_time = time.time()
            page.click_button((By.LINK_TEXT, 'Logs'))
            page.wait_for_element((By.CLASS_NAME, 'logs-list'))
            nav_time = time.time() - start_time
            
            assert nav_time < 3.0, f'Navigation time too slow: {nav_time}s'
            
            page.logout()