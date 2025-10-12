import pytest
import requests

@pytest.mark.usefixtures("endpoints")
class TestCurrencyAPI:
    def test_set_currency(self, endpoints):
        base = endpoints["currency"]
        payload = {
            "currency_code": "GBP"
        }
        resp = requests.post(base, json=payload)
        assert resp.status_code == 302, f"Unexpected {resp.text}"
