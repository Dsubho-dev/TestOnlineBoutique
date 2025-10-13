# test_cart_api.py
import pytest
import httpx


@pytest.mark.usefixtures("endpoints")
class TestCartAPI:
    @pytest.mark.parametrize("product_id,quantity", [
        ("L9ECAV7KIM", 1),
        ("6E92ZMYYFZ", 2),
    ])
    def test_add_to_cart(self, endpoints, product_id, quantity):
        """Add item to cart with form-encoded payload using HTTP/2"""
        base = endpoints["cart"]
        payload = {
            "product_id": product_id,
            "quantity": quantity
        }
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        with httpx.Client(http2=True, verify=False) as client:
            resp = client.post(base, data=payload, headers=headers)
        assert resp.status_code == 302, f"Unexpected {resp.text}"

    def test_get_cart(self, endpoints):
        """Get cart contents using HTTP/2"""
        base = endpoints["cart"]
        with httpx.Client(http2=True) as client:
            resp = client.get(f"{base}?userId=test-user")
        assert resp.status_code == 200, f"Unexpected {resp.text}"

    def test_empty_cart(self, endpoints):
        """Empty the cart via POST and expect 302 on success using HTTP/2"""
        url = endpoints["empty_cart"]
        with httpx.Client(http2=True) as client:
            resp = client.post(url)
        assert resp.status_code == 302, f"Unexpected {resp.text}"
