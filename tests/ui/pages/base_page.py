# base_page.py
# tests/ui/pages/base_page.py
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

class BasePage:
    """Common helper methods for all page objects."""
    def __init__(self, driver, timeout=10):
        self.driver = driver
        self.timeout = timeout
        self.wait = WebDriverWait(driver, timeout)

    def find(self, selector):
        """Find an element by CSS selector with explicit wait."""
        try:
            return self.wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, selector)))
        except TimeoutException:
            raise NoSuchElementException(f"Element with selector '{selector}' not found within {self.timeout} seconds")

    def find_clickable(self, selector):
        """Find a clickable element by CSS selector."""
        return self.wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, selector)))

    def click(self, selector):
        """Click on an element after ensuring it's clickable."""
        element = self.find_clickable(selector)
        element.click()

    def text(self, selector):
        """Get visible text from an element."""
        element = self.find(selector)
        return element.text

    def is_visible(self, selector):
        """Return True if element is visible."""
        try:
            self.wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, selector)))
            return True
        except TimeoutException:
            return False

    def wait_for_element_to_disappear(self, selector):
        """Wait for an element to disappear from the page."""
        try:
            self.wait.until(EC.invisibility_of_element_located((By.CSS_SELECTOR, selector)))
        except TimeoutException:
            pass
