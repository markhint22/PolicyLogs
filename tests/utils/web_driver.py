import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from contextlib import contextmanager
from typing import Optional


class WebDriverManager:
    """Manager for web driver instances used in E2E tests."""
    
    def __init__(self, browser: str = 'chrome', headless: bool = True):
        self.browser = browser.lower()
        self.headless = headless
        self.driver: Optional[webdriver.Remote] = None
    
    def get_driver(self) -> webdriver.Remote:
        """Get configured web driver instance."""
        if self.driver is None:
            self.driver = self._create_driver()
        return self.driver
    
    def _create_driver(self) -> webdriver.Remote:
        """Create web driver based on browser configuration."""
        if self.browser == 'chrome':
            return self._create_chrome_driver()
        elif self.browser == 'firefox':
            return self._create_firefox_driver()
        else:
            raise ValueError(f'Unsupported browser: {self.browser}')
    
    def _create_chrome_driver(self) -> webdriver.Chrome:
        """Create Chrome web driver."""
        options = ChromeOptions()
        
        if self.headless:
            options.add_argument('--headless')
        
        # Add common options for testing
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--disable-gpu')
        options.add_argument('--window-size=1920,1080')
        
        # Disable notifications and popups
        prefs = {
            'profile.default_content_setting_values.notifications': 2,
            'profile.default_content_settings.popups': 0
        }
        options.add_experimental_option('prefs', prefs)
        
        return webdriver.Chrome(options=options)
    
    def _create_firefox_driver(self) -> webdriver.Firefox:
        """Create Firefox web driver."""
        options = FirefoxOptions()
        
        if self.headless:
            options.add_argument('--headless')
        
        options.add_argument('--width=1920')
        options.add_argument('--height=1080')
        
        return webdriver.Firefox(options=options)
    
    def quit(self):
        """Quit web driver if it exists."""
        if self.driver:
            self.driver.quit()
            self.driver = None
    
    def __enter__(self):
        """Context manager entry."""
        return self.get_driver()
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.quit()


class PageHelper:
    """Helper class for common page interactions."""
    
    def __init__(self, driver: webdriver.Remote, base_url: str = 'http://localhost:3000'):
        self.driver = driver
        self.base_url = base_url
        self.wait = WebDriverWait(driver, 10)
    
    def navigate_to(self, path: str = ''):
        """Navigate to specific path."""
        url = f'{self.base_url.rstrip("/")}/{path.lstrip("/")}'
        self.driver.get(url)
    
    def wait_for_element(self, locator: tuple, timeout: int = 10):
        """Wait for element to be present."""
        wait = WebDriverWait(self.driver, timeout)
        return wait.until(EC.presence_of_element_located(locator))
    
    def wait_for_clickable(self, locator: tuple, timeout: int = 10):
        """Wait for element to be clickable."""
        wait = WebDriverWait(self.driver, timeout)
        return wait.until(EC.element_to_be_clickable(locator))
    
    def wait_for_text(self, locator: tuple, text: str, timeout: int = 10):
        """Wait for element to contain specific text."""
        wait = WebDriverWait(self.driver, timeout)
        return wait.until(EC.text_to_be_present_in_element(locator, text))
    
    def fill_form_field(self, locator: tuple, value: str):
        """Fill form field with value."""
        element = self.wait_for_element(locator)
        element.clear()
        element.send_keys(value)
    
    def click_button(self, locator: tuple):
        """Click button and wait for it to be clickable."""
        button = self.wait_for_clickable(locator)
        button.click()
    
    def login(self, username: str, password: str):
        """Perform login action."""
        self.navigate_to('/login')
        
        # Wait for login form
        self.wait_for_element((By.NAME, 'username'))
        
        # Fill login form
        self.fill_form_field((By.NAME, 'username'), username)
        self.fill_form_field((By.NAME, 'password'), password)
        
        # Submit form
        self.click_button((By.TYPE, 'submit'))
        
        # Wait for redirect (assuming successful login redirects)
        self.wait_for_element((By.CLASS_NAME, 'dashboard'), timeout=15)
    
    def logout(self):
        """Perform logout action."""
        logout_button = self.wait_for_clickable((By.CLASS_NAME, 'logout-button'))
        logout_button.click()
        
        # Wait for redirect to login page
        self.wait_for_element((By.NAME, 'username'))
    
    def is_logged_in(self) -> bool:
        """Check if user is currently logged in."""
        try:
            self.wait_for_element((By.CLASS_NAME, 'user-menu'), timeout=2)
            return True
        except TimeoutException:
            return False
    
    def take_screenshot(self, filename: str):
        """Take screenshot and save to file."""
        screenshots_dir = os.path.join(os.path.dirname(__file__), '..', 'screenshots')
        os.makedirs(screenshots_dir, exist_ok=True)
        
        filepath = os.path.join(screenshots_dir, filename)
        self.driver.save_screenshot(filepath)
        return filepath


@contextmanager
def web_driver_session(browser: str = 'chrome', headless: bool = True):
    """Context manager for web driver sessions."""
    manager = WebDriverManager(browser=browser, headless=headless)
    driver = manager.get_driver()
    
    try:
        yield PageHelper(driver)
    finally:
        manager.quit()