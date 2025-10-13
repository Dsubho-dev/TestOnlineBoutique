# test_add_to_cart_ui.py
# tests/ui/test_add_to_cart_ui.py
import pytest
from tests.ui.pages.product_page import ShopPage
from tests.ui.pages.add_to_cart_page import AddToCartPage

@pytest.mark.ui
def test_add_to_cart_flow(driver, base_url):
    """E2E test: open shop, add item to cart, verify cart count updates."""
    driver.get(base_url)
    page = AddToCartPage(driver)

    # Verify that products load correctly
    assert page.verify_products_loaded(), "Products not loaded on homepage"
    
    # Verify we have products to add to cart
    product_count = page.get_product_count()
    print(f"📦 Found {product_count} products on the page")
    assert product_count > 0, "No products available to add to cart"

    # Get initial cart count
    initial_count = page.get_cart_count()
    print(f"🛒 Initial cart count: {initial_count}")

    # Add first product to cart
    page.add_first_product_to_cart()
    print("✅ Successfully clicked add to cart")

    # Wait a moment for cart to update
    import time
    time.sleep(2)

    # Validate cart counter increased
    final_count = page.get_cart_count()
    print(f"🛒 Final cart count: {final_count}")
    
    assert final_count > initial_count, f"Cart count did not increase. Initial: {initial_count}, Final: {final_count}"
    assert final_count >= 1, f"Expected cart count >=1, got {final_count}"
