# Define ui fixtures
import pytest
import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.chrome.options import Options as ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager


@pytest.fixture(scope="function")  # Changed to function scope for better isolation
def driver():
    """Initialize a Chrome WebDriver for UI tests."""
    options = ChromeOptions()
    
    # Add Chrome options for better stability
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-plugins")
    options.add_argument("--disable-images")  # Faster loading
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--start-maximized")
    
    # Enable headless mode based on environment variable
    if os.getenv("HEADLESS", "true").lower() == "true":
        options.add_argument("--headless=new")
    
    # Additional options for CI/CD environments
    options.add_argument("--disable-background-timer-throttling")
    options.add_argument("--disable-backgrounding-occluded-windows")
    options.add_argument("--disable-renderer-backgrounding")
    
    try:
        # Initialize driver
        service = ChromeService(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=options)
        
        # Set timeouts
        driver.implicitly_wait(10)
        driver.set_page_load_timeout(30)
        
        print(f"🚀 Chrome WebDriver initialized successfully")
        yield driver
        
    except Exception as e:
        print(f"❌ Failed to initialize WebDriver: {e}")
        raise
    finally:
        try:
            if 'driver' in locals():
                driver.quit()
                print("🛑 WebDriver session ended")
        except:
            pass


@pytest.fixture(scope="session")
def base_url():
    """Base URL for the application."""
    return os.getenv("BASE_URL", "http://localhost:8081")
