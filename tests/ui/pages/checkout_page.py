# tests/ui/pages/checkout_page.py
from .base_page import BasePage

class CheckoutPage(BasePage):
    """Page object for the checkout flow."""

    CHECKOUT_BTN = ".cart-checkout"
    NAME_FIELD = "input[name='name']"
    ADDRESS_FIELD = "input[name='address']"
    CITY_FIELD = "input[name='city']"
    ZIP_FIELD = "input[name='zip']"
    CREDIT_CARD_FIELD = "input[name='creditCard']"
    PLACE_ORDER_BTN = "button[type='submit']"
    CONFIRMATION_TEXT = ".confirmation"

    def start_checkout(self):
        """Click checkout button from cart page."""
        self.click(self.CHECKOUT_BTN)

    def fill_checkout_form(self, name, address, city, zip_code, card):
        """Fill in checkout form fields."""
        self.find(self.NAME_FIELD).send_keys(name)
        self.find(self.ADDRESS_FIELD).send_keys(address)
        self.find(self.CITY_FIELD).send_keys(city)
        self.find(self.ZIP_FIELD).send_keys(zip_code)
        self.find(self.CREDIT_CARD_FIELD).send_keys(card)

    def place_order(self):
        """Submit checkout form."""
        self.click(self.PLACE_ORDER_BTN)

    def is_order_confirmed(self):
        """Check if confirmation message appears."""
        return self.is_visible(self.CONFIRMATION_TEXT)
