# base_page.py
# tests/ui/pages/base_page.py
from selenium.webdriver.common.by import By

class BasePage:
    """Common helper methods for all page objects."""
    def __init__(self, driver):
        self.driver = driver

    def find(self, selector):
        """Find an element by CSS selector."""
        return self.driver.find_element(By.CSS_SELECTOR, selector)

    def click(self, selector):
        """Click on an element."""
        self.find(selector).click()

    def text(self, selector):
        """Get visible text from an element."""
        return self.find(selector).text

    def is_visible(self, selector):
        """Return True if element is visible."""
        return len(self.driver.find_elements(By.CSS_SELECTOR, selector)) > 0
