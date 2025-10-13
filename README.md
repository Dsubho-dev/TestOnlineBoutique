# TestOnlineBoutique

A comprehensive test framework to deploy and test microservices with both API and UI testing capabilities.

## Prerequisites

- Python 3.8 or higher
- pip (Python package installer)
- Git

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd TestOnlineBoutique-main
```

### 2. Create and Activate Virtual Environment

#### On Windows (PowerShell/CMD):
```powershell
# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate
```

#### On macOS/Linux:
```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Verify Installation

```bash
pytest --version
python -c "import selenium; print('Selenium installed successfully')"
```

## Running Tests

The test suite includes both API and UI tests, organized with pytest markers for easy execution.

### Test Structure

```
tests/
├── api/                    # API tests
│   ├── test_cart_api.py
│   ├── test_catalog_api.py
│   ├── test_checkout_api.py
│   └── test_currency_api.py
├── ui/                     # UI tests
│   ├── test_add_to_cart_ui.py
│   └── test_checkout_ui.py
└── config/                 # Test configuration
    ├── pytest.ini
    └── env.yaml
```

### Running All Tests

```bash
# Run all tests
pytest

# Run tests with verbose output
pytest -v

# Run tests with detailed output and show local variables on failure
pytest -v -l
```

### Running API Tests Only

```bash
# Run all API tests
pytest -m api

# Run specific API test file
pytest tests/api/test_cart_api.py

# Run specific test function
pytest tests/api/test_cart_api.py::TestCartAPI::test_add_to_cart
```

### Running UI Tests Only

```bash
# Run all UI tests
pytest -m ui

# Run specific UI test file
pytest tests/ui/test_add_to_cart_ui.py

# Run UI tests with browser visible (if headless mode is default)
pytest -m ui --headless=false
```

### Advanced Test Execution

```bash
# Run tests in parallel (if pytest-xdist is installed)
pytest -n auto

# Run tests and generate HTML report
pytest --html=report.html --self-contained-html

# Run tests with coverage report
pytest --cov=tests --cov-report=html

# Run tests excluding slow tests
pytest -m "not slow"

# Run only integration tests
pytest -m integration

# Run tests with custom timeout
pytest --timeout=60
```

### Test Configuration

The test configuration is managed through:

- **pytest.ini**: Main pytest configuration including markers, test paths, and output settings
- **env.yaml**: Environment-specific configuration (currently empty, can be customized)
- **conftest.py**: Shared fixtures and test setup

### Available Test Markers

- `api`: API tests
- `ui`: UI tests  
- `slow`: Slow-running tests
- `integration`: Integration tests

### Troubleshooting

#### Virtual Environment Issues
```bash
# Deactivate current environment
deactivate

# Remove and recreate virtual environment
rmdir /s venv  # Windows
rm -rf venv    # macOS/Linux

# Recreate environment
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux
pip install -r requirements.txt
```

#### Browser Driver Issues (for UI tests)
The project uses `webdriver-manager` which automatically downloads and manages browser drivers. If you encounter issues:

```bash
# Clear webdriver cache
python -c "from webdriver_manager.chrome import ChromeDriverManager; ChromeDriverManager().install()"
```

#### Common Test Failures
- **Connection errors**: Ensure the target application is running and accessible
- **Timeout errors**: Increase timeout values in pytest.ini or use `--timeout` parameter
- **Browser not found**: Install Chrome/Firefox or specify a different browser in test configuration

## Development

### Adding New Tests

1. **API Tests**: Add new test files in `tests/api/` following the naming convention `test_*_api.py`
2. **UI Tests**: Add new test files in `tests/ui/` following the naming convention `test_*_ui.py`
3. **Use appropriate markers**: Decorate tests with `@pytest.mark.api` or `@pytest.mark.ui`

### Test Data

- **API test data**: Located in `tests/api/testdata/`
- **UI test data**: Located in `tests/ui/testdata/`

## Infrastructure

The project includes infrastructure setup scripts in the `infra/` directory for setting up test environments using Kind (Kubernetes in Docker).

## Contributing

1. Create a new branch for your feature/fix
2. Write tests for new functionality
3. Ensure all tests pass: `pytest`
4. Submit a pull request

## License

[Add your license information here]
