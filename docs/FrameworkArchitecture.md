# Framework Architecture

## Overview

This document outlines the comprehensive testing framework architecture for the Online Boutique microservices application. The framework supports both API and UI testing with a focus on maintainability, scalability, and reliability.

## Test Architecture

### High-Level Architecture

```
TestOnlineBoutique/
├── tests/
│   ├── api/           # API testing layer
│   ├── ui/            # UI testing layer
│   └── config/        # Test configuration
├── go-coverage/       # Go service coverage collection
├── infra/            # Infrastructure setup
└── ci/               # CI/CD configurations
```

### Testing Layers

#### 1. API Testing Layer (`tests/api/`)
- **Purpose**: Tests microservice APIs directly via HTTP calls
- **Scope**: Service-to-service communication, data validation, error handling
- **Test Types**: Unit, Integration, Contract testing

#### 2. UI Testing Layer (`tests/ui/`)
- **Purpose**: End-to-end user journey validation
- **Scope**: Frontend functionality, user interactions, visual validation
- **Test Types**: E2E, Smoke, Regression testing

#### 3. Go Service Coverage (`go-coverage/`)
- **Purpose**: Unit test coverage collection for Go microservices
- **Scope**: Code coverage metrics and reporting
- **Integration**: Automated coverage collection and reporting

## Framework Components

### Core Testing Framework: pytest

**Rationale**: pytest provides excellent support for:
- Parameterized testing
- Fixtures for setup/teardown
- Markers for test categorization
- Rich reporting capabilities
- Plugin ecosystem

### API Testing Stack

#### HTTP Client: httpx
- **Features**: HTTP/2 support, async capabilities, connection pooling
- **Usage**: All API requests use httpx with HTTP/2 enabled
- **Benefits**: Better performance, modern protocol support

#### Configuration Management
- **endpoints.yaml**: Service endpoint configuration
- **conftest.py**: Shared fixtures and service health checks
- **Environment-based**: Configurable URLs via environment variables

#### Test Structure
```python
@pytest.mark.parametrize("product_id,quantity", [
    ("L9ECAV7KIM", 1),
    ("6E92ZMYYFZ", 2),
])
def test_add_to_cart(self, endpoints, product_id, quantity):
    # Test implementation with data-driven approach
```

### UI Testing Stack

#### WebDriver: Selenium + ChromeDriver
- **WebDriver Manager**: Automatic driver management
- **Chrome Options**: Optimized for stability and performance
- **Headless Support**: Environment-controlled headless execution

#### Page Object Model (POM)
```
tests/ui/pages/
├── base_page.py        # Common page operations
├── add_to_cart_page.py # Cart functionality
├── checkout_page.py    # Checkout process
└── product_page.py     # Product catalog
```

**Benefits**:
- Code reusability
- Maintainable test scripts
- Separation of concerns
- Easy updates for UI changes

#### Base Page Implementation
```python
class BasePage:
    def __init__(self, driver, timeout=10):
        self.driver = driver
        self.timeout = timeout
        self.wait = WebDriverWait(driver, timeout)
    
    def find(self, selector):
        return self.wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, selector)))
```

## Test Configuration

### pytest Configuration (`pytest.ini`)

#### Test Markers
- `@pytest.mark.api`: API tests
- `@pytest.mark.ui`: UI tests  
- `@pytest.mark.slow`: Long-running tests
- `@pytest.mark.integration`: Integration tests

#### Test Discovery
- **Test Paths**: `testpaths = tests`
- **Pattern**: `test_*.py` files
- **Classes**: `Test*` classes
- **Functions**: `test_*` functions

#### Execution Settings
- **Timeout**: 300 seconds per test
- **Output**: Progress style with verbose reporting
- **Colors**: Enabled for better readability
- **Strict Markers**: Prevents typos in marker names

### Environment Configuration

#### Service Endpoints (`endpoints.yaml`)
```yaml
cart: "http://localhost:8081/cart"
catalog: "http://localhost:8081/product"
checkout: "http://localhost:8081/cart/checkout"
currency: "http://localhost:8081/setCurrency"
```

#### UI Configuration
- **Base URL**: `http://localhost:8080` (configurable via `BASE_URL` env var)
- **Headless Mode**: Controlled via `HEADLESS` environment variable
- **Browser Options**: Optimized for CI/CD environments

## Fixture Architecture

### Session-Level Fixtures
- **endpoints**: Loads service endpoints configuration
- **check_services_health**: Pre-test health validation
- **base_url**: Application base URL configuration

### Function-Level Fixtures
- **driver**: WebDriver instance with optimal configuration
- **Isolation**: Each test gets fresh driver instance

### Health Check Strategy
```python
@pytest.fixture(scope="session")
def check_services_health(endpoints):
    for name, url in endpoints.items():
        try:
            resp = requests.get(url, timeout=5)
            print(f"[HEALTH] {name}: {resp.status_code}")
        except Exception as e:
            print(f"[WARN] {name} not reachable: {e}")
```

## Test Execution Strategy

### Local Development
```bash
# Run all tests
make test

# Run specific test types
make test-api
make test-ui

# Run with specific markers
pytest -m "api and not slow"
pytest -m "ui" --headless
```

### CI/CD Integration
- **Infrastructure Setup**: Automated via `make setup`
- **Test Execution**: Parallel execution support
- **Coverage Collection**: Integrated Go coverage collection
- **Cleanup**: Automated teardown via `make clean`

## Coverage and Reporting

### Go Services Coverage
- **Collection Script**: `go-coverage/collect_coverage.sh`
- **Instrumentation**: `go-coverage/enable_coverage.sh` 
- **Reporting**: HTML and summary reports
- **Integration**: Makefile targets for automation

### Python Test Coverage
- **Framework**: Built-in pytest coverage tracking
- **Reporting**: Console and file output
- **Integration**: CI/CD pipeline integration

## Framework Benefits

### Maintainability
- **Page Object Model**: Centralized UI element management
- **Configuration-Driven**: Easy environment switching
- **Modular Design**: Clear separation of concerns

### Scalability
- **Parallel Execution**: pytest-xdist support
- **Marker-Based Filtering**: Selective test execution
- **Parameterized Tests**: Data-driven test expansion

### Reliability
- **Health Checks**: Pre-test service validation
- **Explicit Waits**: Robust element interactions
- **Error Handling**: Graceful failure management
- **Retry Mechanisms**: Built-in retry strategies

### Observability
- **Rich Reporting**: Detailed test execution reports
- **Coverage Metrics**: Code coverage tracking
- **Performance Metrics**: Execution time tracking
- **Logging Integration**: Comprehensive logging

## Best Practices

### Test Design
1. **Atomic Tests**: Each test validates single functionality
2. **Data-Driven**: Use parameterization for test variations
3. **Independent Tests**: No test dependencies
4. **Clear Assertions**: Descriptive assertion messages

### Code Organization
1. **POM Pattern**: UI elements abstracted in page objects
2. **Fixture Reuse**: Common setup via pytest fixtures
3. **Configuration Management**: Environment-based configuration
4. **Error Handling**: Comprehensive exception handling

### Execution Guidelines
1. **Health Checks**: Always validate service availability
2. **Cleanup**: Proper resource cleanup after tests
3. **Parallel Execution**: Use markers for parallel-safe tests
4. **Environment Isolation**: Clean state between test runs

## Future Enhancements

### Planned Improvements
1. **Visual Testing**: Screenshot comparison capabilities
2. **Performance Testing**: Load testing integration
3. **API Contract Testing**: Schema validation
4. **Cross-Browser Testing**: Multi-browser support
5. **Mobile Testing**: Responsive design validation

### Technical Debt
1. **Flakiness Reduction**: Enhanced wait strategies
2. **Test Data Management**: Dynamic test data generation
3. **Reporting Enhancement**: Advanced reporting dashboards
4. **CI/CD Optimization**: Faster feedback loops
