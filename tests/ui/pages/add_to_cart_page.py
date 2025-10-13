# add_to_cart_page.py
# tests/ui/pages/add_to_cart_page.py
from .base_page import BasePage

class AddToCartPage(BasePage):
    """Page object for add to cart functionality on the Online Boutique."""

    # More specific selectors for Online Boutique application
    PRODUCT_CARD = ".product-card, .product"
    ADD_TO_CART_BTN = "button[type='submit'], .btn-primary, input[type='submit']"
    CART_COUNT = ".cart-size, .cart-count, [data-cy='cart-count']"
    PRODUCT_LIST = ".products-container, .product-list"
    LOADING_INDICATOR = ".loading, .spinner"

    def add_first_product_to_cart(self):
        """Click the 'Add to cart' button of the first product."""
        # Wait for products to load
        self.wait_for_products_to_load()
        
        # Find the first product and its add to cart button
        selector = f"{self.PRODUCT_CARD}:first-child {self.ADD_TO_CART_BTN}"
        try:
            self.click(selector)
        except Exception as e:
            # Fallback: try different selectors
            fallback_selectors = [
                f"{self.PRODUCT_CARD}:first-of-type {self.ADD_TO_CART_BTN}",
                f"{self.PRODUCT_CARD}:nth-child(1) {self.ADD_TO_CART_BTN}",
                f"{self.ADD_TO_CART_BTN}:first-of-type"
            ]
            for fallback in fallback_selectors:
                try:
                    self.click(fallback)
                    return
                except:
                    continue
            raise e

    def get_cart_count(self):
        """Return integer cart count from UI."""
        try:
            cart_text = self.text(self.CART_COUNT)
            # Extract numeric value from text (handles cases like "Cart (1)" or "1 items")
            import re
            numbers = re.findall(r'\d+', cart_text)
            return int(numbers[0]) if numbers else 0
        except:
            return 0

    def verify_products_loaded(self):
        """Ensure that product cards are visible."""
        # Wait for loading to finish if present
        if self.is_visible(self.LOADING_INDICATOR):
            self.wait_for_element_to_disappear(self.LOADING_INDICATOR)
        
        return self.is_visible(self.PRODUCT_CARD)

    def wait_for_products_to_load(self):
        """Wait for products to be fully loaded on the page."""
        # Wait for loading indicator to disappear
        if self.is_visible(self.LOADING_INDICATOR):
            self.wait_for_element_to_disappear(self.LOADING_INDICATOR)
        
        # Ensure at least one product is visible
        assert self.is_visible(self.PRODUCT_CARD), "No products found on the page"

    def get_product_count(self):
        """Return the number of products visible on the page."""
        try:
            from selenium.webdriver.common.by import By
            products = self.driver.find_elements(By.CSS_SELECTOR, self.PRODUCT_CARD)
            return len(products)
        except:
            return 0
