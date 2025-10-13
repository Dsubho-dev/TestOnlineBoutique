import pytest
import httpx


@pytest.mark.usefixtures("endpoints")
class TestCheckoutAPI:
    def test_place_order(self, endpoints):
        base = endpoints["checkout"]

        # ✅ Use snake_case field names exactly as in successful query
        payload = {
            "email": "test@example.com",
            "street_address": "1600 Amphitheatre Parkway",
            "zip_code": "94043",
            "city": "Mountain View",
            "state": "CA",
            "country": "United States",
            "credit_card_number": "4111111111111111",
            "credit_card_expiration_month": 12,
            "credit_card_expiration_year": 2025,
            "credit_card_cvv": "123",
        }

        headers = {"Content-Type": "application/x-www-form-urlencoded"}

        with httpx.Client(http2=True, follow_redirects=False) as client:
            resp = client.post(base, data=payload, headers=headers)

        # ✅ Expect redirect after successful checkout
        assert resp.status_code == 200, f"Unexpected {resp.status_code}: {resp.text}"
