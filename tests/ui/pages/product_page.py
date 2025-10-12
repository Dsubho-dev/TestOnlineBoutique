# product_page.py
# tests/ui/pages/shop_page.py
from .base_page import BasePage

class ShopPage(BasePage):
    """Page object for the Online Boutique home/shop page."""

    PRODUCT_CARD = ".product"
    ADD_TO_CART_BTN = ".btn-primary"
    CART_COUNT = ".cart-count"

    def add_first_product_to_cart(self):
        """Click the 'Add to cart' button of the first product."""
        selector = f"{self.PRODUCT_CARD}:first-child {self.ADD_TO_CART_BTN}"
        self.click(selector)

    def get_cart_count(self):
        """Return integer cart count from UI."""
        return int(self.text(self.CART_COUNT))

    def verify_products_loaded(self):
        """Ensure that product cards are visible."""
        return self.is_visible(self.PRODUCT_CARD)
