# Makefile for TestOnlineBoutique

.PHONY: help setup test test-api test-ui go-coverage go-coverage-enable clean coverage-clean

# Default target
help:
	@echo "Available targets:"
	@echo "  setup              - Set up the infrastructure and deploy services"
	@echo "  test               - Run all tests (API + UI)"
	@echo "  test-api           - Run API tests only"
	@echo "  test-ui            - Run UI tests only"
	@echo "  go-coverage        - Collect Go coverage from unit tests"
	@echo "  go-coverage-enable - Enable coverage instrumentation for container builds"
	@echo "  coverage-clean     - Clean coverage artifacts"
	@echo "  clean              - Clean all artifacts"

# Infrastructure setup
setup:
	@echo "🚀 Setting up infrastructure..."
	cd infra && ./setup.sh

# Run all tests
test: test-api test-ui

# Run API tests
test-api:
	@echo "🧪 Running API tests..."
	cd tests && python -m pytest api/ -v

# Run UI tests
test-ui:
	@echo "🖥️ Running UI tests..."
	cd tests && python -m pytest ui/ -v

# Go coverage collection from unit tests
go-coverage:
	@echo "📊 Collecting Go coverage from unit tests..."
	cd go-coverage && chmod +x collect_coverage.sh && ./collect_coverage.sh

# Enable Go coverage instrumentation for containers
go-coverage-enable:
	@echo "🔧 Enabling Go coverage instrumentation..."
	cd go-coverage && chmod +x enable_coverage.sh && ./enable_coverage.sh

# Clean coverage artifacts
coverage-clean:
	@echo "🧹 Cleaning coverage artifacts..."
	rm -rf go-coverage/results/
	find microservices-demo-main/src -name "coverage.out" -delete 2>/dev/null || true
	find microservices-demo-main/src -name "Dockerfile.coverage" -delete 2>/dev/null || true
	rm -f microservices-demo-main/skaffold-coverage.yaml 2>/dev/null || true

# Clean all artifacts
clean: coverage-clean
	@echo "🧹 Cleaning all artifacts..."
	cd infra && ./teardown.sh
