# Go Coverage Reporting for Microservices

This directory contains tools and scripts for collecting and reporting test coverage from the Go microservices in the Online Boutique demo application.

## Overview

The following Go services are instrumented for coverage reporting:
- **frontend** - HTTP server serving the web application
- **shippingservice** - Shipping cost calculation service
- **productcatalogservice** - Product catalog management service  
- **checkoutservice** - Order processing and checkout service

## Quick Start

### Unit Test Coverage Collection

To collect coverage from unit tests (recommended for development):

```bash
# From the project root directory
make go-coverage
```

Or run directly:

```bash
cd go-coverage
./collect_coverage.sh
```

This will:
1. Run unit tests for all Go services with coverage enabled
2. Generate individual coverage reports for each service
3. Merge all coverage data into a combined report
4. Generate HTML visualization of coverage results

### Runtime Coverage Collection (Advanced)

For collecting coverage from running containers in integration tests:

```bash
# Enable coverage instrumentation
make go-coverage-enable

# This creates:
# - Dockerfile.coverage files for each Go service
# - skaffold-coverage.yaml for building instrumented images
```

## Files and Scripts

### `collect_coverage.sh`
Main script for collecting unit test coverage data.

**Features:**
- Automatically discovers all Go services
- Runs `go test` with coverage flags for each service
- Merges coverage data from multiple services
- Generates both text and HTML coverage reports
- Provides per-service coverage summaries

**Usage:**
```bash
./collect_coverage.sh
```

**Output:**
- `results/combined_coverage.out` - Merged coverage data
- `results/combined_coverage.html` - HTML coverage report
- `results/*_coverage.out` - Individual service coverage files

### `enable_coverage.sh`
Script for enabling runtime coverage instrumentation in containerized deployments.

**Features:**
- Creates coverage-enabled Dockerfiles for each Go service
- Modifies skaffold configuration for instrumented builds
- Adds necessary environment variables and directories

**Usage:**
```bash
./enable_coverage.sh
```

### `create_coverage_dockerfiles.sh`
Helper script to generate standardized coverage-enabled Dockerfiles.

**Features:**
- Creates consistent Dockerfile.coverage files
- Adds `-cover` build flag to Go compilation
- Sets up `/tmp/coverage` directory in containers
- Configures `GOCOVERDIR` environment variable

## Coverage Reports

### HTML Report
The main coverage report is generated at `results/combined_coverage.html`. Open this file in a web browser to see:
- Line-by-line coverage visualization
- File-by-file coverage percentages  
- Function-by-function coverage details
- Interactive source code browsing

### Text Summary
Coverage summaries are printed to the console showing:
- Overall coverage percentage across all services
- Per-file coverage percentages
- Per-function coverage details

## Integration with CI/CD

### GitHub Actions Integration
The coverage collection can be integrated with the existing CI/CD pipeline by adding to `.github/workflows/ci-pr.yaml`:

```yaml
- name: Go Coverage Collection
  run: |
    cd go-coverage
    ./collect_coverage.sh
    
- name: Upload Coverage Reports
  uses: actions/upload-artifact@v3
  with:
    name: go-coverage-reports
    path: go-coverage/results/
```

### Makefile Targets
Available make targets:
- `make go-coverage` - Collect unit test coverage
- `make go-coverage-enable` - Enable container coverage instrumentation
- `make coverage-clean` - Clean coverage artifacts

## Runtime Coverage Collection

For integration testing scenarios where you want coverage from running services:

1. **Build instrumented images:**
   ```bash
   skaffold build -f skaffold-coverage.yaml
   ```

2. **Deploy with coverage enabled:**
   ```bash
   skaffold deploy -f skaffold-coverage.yaml
   ```

3. **Run your integration tests against the deployed services**

4. **Extract coverage data from containers:**
   ```bash
   kubectl cp <pod-name>:/tmp/coverage ./coverage-data/
   ```

5. **Process the coverage files:**
   ```bash
   go tool covdata textfmt -i=./coverage-data -o=runtime_coverage.out
   go tool cover -html=runtime_coverage.out -o=runtime_coverage.html
   ```

## Troubleshooting

### No Coverage Data Generated
- Ensure tests exist for the service (`*_test.go` files)
- Check that `go test` runs successfully without coverage flags
- Verify the service has a valid `go.mod` file

### Tests Failing
- Run `go test` manually in the service directory to debug
- Check for missing dependencies with `go mod tidy`
- Ensure proper Go version (1.23+ required)

### Merged Coverage Issues
- Individual service coverage files must use the same coverage mode (`atomic`)
- Check that all services are using compatible Go versions
- Ensure no duplicate package paths across services

## Coverage Thresholds

Consider setting coverage thresholds for quality gates:
- **Minimum per-service coverage:** 60%
- **Combined coverage target:** 70%
- **Critical path coverage:** 90%

Add to CI pipeline:
```bash
# Fail if coverage is below threshold
COVERAGE=$(go tool cover -func=results/combined_coverage.out | tail -1 | awk '{print $3}' | sed 's/%//')
if (( $(echo "$COVERAGE < 70" | bc -l) )); then
  echo "Coverage $COVERAGE% is below threshold of 70%"
  exit 1
fi
```

## Best Practices

1. **Run coverage regularly** during development
2. **Focus on testing business logic** over generated code
3. **Use table-driven tests** for better coverage of edge cases
4. **Mock external dependencies** to ensure consistent test execution
5. **Review coverage reports** to identify untested code paths
6. **Set up coverage trending** to track improvements over time

## Contributing

When adding new Go services:
1. Add the service name to the `SERVICES` array in `collect_coverage.sh`
2. Ensure the service has proper unit tests
3. Test coverage collection locally before submitting PR
4. Update this README if new patterns or requirements emerge
