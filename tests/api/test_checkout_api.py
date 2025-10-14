import pytest
import httpx


@pytest.mark.usefixtures("endpoints", "user_data")
class TestCheckoutAPI:
    def test_place_order(self, endpoints, user_data):
        base = endpoints["checkout"]

        # Use user data from JSON file
        payload = user_data["valid_users"]["default_user"]

        headers = {"Content-Type": "application/x-www-form-urlencoded"}

        with httpx.Client(http2=True, follow_redirects=False) as client:
            resp = client.post(base, data=payload, headers=headers)

        # Expect redirect after successful checkout
        assert resp.status_code == 200, f"Unexpected {resp.status_code}: {resp.text}"
    
    def test_place_order_premium_user(self, endpoints, user_data):
        """Test checkout with premium user data."""
        base = endpoints["checkout"]
        
        # Use premium user data from JSON
        payload = user_data["valid_users"]["premium_user"]
        
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        
        with httpx.Client(http2=True, follow_redirects=False) as client:
            resp = client.post(base, data=payload, headers=headers)
        
        assert resp.status_code == 200, f"Unexpected {resp.status_code}: {resp.text}"
    