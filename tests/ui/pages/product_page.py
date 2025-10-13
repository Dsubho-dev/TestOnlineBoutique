# product_page.py
# tests/ui/pages/product_page.py
from .base_page import BasePage

class ShopPage(BasePage):
    """Page object for the Online Boutique product/shop page."""

    # Selectors for product page elements
    PRODUCT_CARD = ".product-card, .product"
    PRODUCT_NAME = ".product-name, h2"
    PRODUCT_PRICE = ".product-price, .price"
    ADD_TO_CART_BTN = "button[type='submit'], .btn-primary, input[type='submit']"
    CART_COUNT = ".cart-size, .cart-count, [data-cy='cart-count']"
    PRODUCT_IMAGE = ".product-image, img"
    QUANTITY_INPUT = "input[name='quantity'], .quantity-input"

    def add_first_product_to_cart(self):
        """Click the 'Add to cart' button of the first product."""
        # Wait for products to load
        assert self.verify_products_loaded(), "Products not loaded before attempting to add to cart"
        
        selector = f"{self.PRODUCT_CARD}:first-child {self.ADD_TO_CART_BTN}"
        self.click(selector)

    def get_cart_count(self):
        """Return integer cart count from UI."""
        try:
            cart_text = self.text(self.CART_COUNT)
            # Extract numeric value
            import re
            numbers = re.findall(r'\d+', cart_text)
            return int(numbers[0]) if numbers else 0
        except:
            return 0

    def verify_products_loaded(self):
        """Ensure that product cards are visible."""
        return self.is_visible(self.PRODUCT_CARD)

    def get_first_product_name(self):
        """Get the name of the first product."""
        selector = f"{self.PRODUCT_CARD}:first-child {self.PRODUCT_NAME}"
        return self.text(selector)

    def get_first_product_price(self):
        """Get the price of the first product."""
        selector = f"{self.PRODUCT_CARD}:first-child {self.PRODUCT_PRICE}"
        return self.text(selector)
