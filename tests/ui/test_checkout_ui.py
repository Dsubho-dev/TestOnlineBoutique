# test_checkout_ui.py
# tests/ui/test_checkout_ui.py
import pytest
from tests.ui.pages.product_page import ShopPage
from tests.ui.pages.checkout_page import CheckoutPage

@pytest.mark.ui
def test_checkout_flow(driver, base_url):
    """End-to-end UI test: Add product, proceed to checkout, place order."""
    driver.get(base_url)

    shop = ShopPage(driver)
    checkout = CheckoutPage(driver)

    # Step 1: Ensure products load
    assert shop.verify_products_loaded(), "Products not visible on home page"

    # Step 2: Add first product to cart
    shop.add_first_product_to_cart()
    assert shop.get_cart_count() >= 1, "Cart count did not increase"

    # Step 3: Click checkout button
    checkout.start_checkout()

    # Step 4: Fill in checkout form
    checkout.fill_checkout_form(
        name="John Doe",
        address="1600 Amphitheatre Pkwy",
        city="Mountain View",
        zip_code="94043",
        card="4111111111111111"
    )

    # Step 5: Place order
    checkout.place_order()

    # Step 6: Verify confirmation message
    assert checkout.is_order_confirmed(), "Order confirmation not visible"

    print("✅ Checkout flow completed successfully")
