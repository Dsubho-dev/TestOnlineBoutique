# test_catalog_api.py
import pytest
import requests


@pytest.mark.usefixtures("endpoints")
class TestCatalogAPI:
    def test_get_products(self, endpoints):
        base = endpoints["catalog"]
        resp = requests.get(base)
        assert resp.status_code == 200
        data = resp.json()
        assert isinstance(data, list)
        assert "id" in data[0]

    @pytest.mark.parametrize("product_id", ["66VCHSJNUP", "2ZYFJ3GM2N"])
    def test_get_product_details(self, endpoints, product_id):
        base = endpoints["catalog"]
        resp = requests.get(f"{base}/{product_id}")
        assert resp.status_code == 200
        assert "name" in resp.json()
