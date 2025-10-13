# test_catalog_api.py
import pytest
import httpx


@pytest.mark.usefixtures("endpoints")
class TestCatalogAPI:
    
    @pytest.mark.parametrize("product_id", ["66VCHSJNUP", "2ZYFJ3GM2N"])
    def test_get_product_details(self, endpoints, product_id):
        base = endpoints["catalog"]
        with httpx.Client(http2=True) as client:
            resp = client.get(f"{base}/{product_id}")
        assert resp.status_code == 200
