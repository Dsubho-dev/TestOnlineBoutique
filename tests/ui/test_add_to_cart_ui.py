# test_add_to_cart_ui.py
# tests/ui/test_add_to_cart_ui.py
import pytest
from tests.ui.pages.product_page import ShopPage

BASE_URL = "http://localhost:8080"

@pytest.mark.ui
def test_add_to_cart_flow(driver):
    """E2E test: open shop, add item to cart, verify cart count updates."""
    driver.get(BASE_URL)
    page = ShopPage(driver)

    # Verify that products load correctly
    assert page.verify_products_loaded(), "Products not loaded on homepage"

    # Add first product to cart
    page.add_first_product_to_cart()

    # Validate cart counter
    count = page.get_cart_count()
    assert count >= 1, f"Expected cart count >=1, got {count}"

    print(f"🛒 Cart count after adding: {count}")
