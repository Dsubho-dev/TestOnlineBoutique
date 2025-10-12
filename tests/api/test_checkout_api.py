# test_checkout_api.py
import pytest
import requests


@pytest.mark.usefixtures("endpoints")
class TestCheckoutAPI:
    def test_place_order(self, endpoints):
        base = endpoints["checkout"]
        payload = {
            "userId": "user-1",
            "userCurrency": "USD",
            "address": {
                "streetAddress": "1600 Amphitheatre Parkway",
                "city": "Mountain View",
                "state": "CA",
                "country": "USA",
                "zipCode": "94043"
            },
            "email": "test@example.com",
            "creditCard": {
                "number": "4111111111111111",
                "cvv": "123",
                "expirationMonth": 12,
                "expirationYear": 2025
            }
        }
        resp = requests.post(base, json=payload)
        assert resp.status_code == 302, f"Unexpected {resp.text}"
