import pytest
import httpx

@pytest.mark.usefixtures("endpoints")
class TestCurrencyAPI:
    def test_set_currency(self, endpoints):
        base = endpoints["currency"]
        payload = {
            "currency_code": "GBP"
        }
        headers = {"Content-Type": "application/x-www-form-urlencoded"}
        with httpx.Client(http2=True, follow_redirects=False) as client:
            resp = client.post(base, data=payload, headers=headers)
        assert resp.status_code == 302, f"Unexpected {resp.text}"
