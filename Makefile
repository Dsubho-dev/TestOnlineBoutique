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
	@echo "  clean              - Clean all artifacts, delete kind cluster"

# Infrastructure setup
setup:
	@echo "🚀 Setting up infrastructure..."
	chmod +x infra/setup.sh && ./infra/setup.sh

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
	chmod +x go-coverage/collect_coverage.sh && ./go-coverage/collect_coverage.sh || { \
		echo "⚠️  Go coverage collection had some issues but may have partial results"; \
		echo "📁 Check go-coverage/ directory for any generated reports"; \
		exit 0; \
	}

# Enable Go coverage instrumentation for containers
go-coverage-enable:
	@echo "🔧 Enabling Go coverage instrumentation..."
	chmod +x go-coverage/enable_coverage.sh && ./go-coverage/enable_coverage.sh

# Clean coverage artifacts
coverage-clean:
	@echo "🧹 Cleaning coverage artifacts..."
	rm -rf go-coverage/results/
	find microservices-demo-main/src -name "coverage.out" -delete 2>/dev/null || true
	find microservices-demo-main/src -name "Dockerfile.coverage" -delete 2>/dev/null || true
	rm -f microservices-demo-main/skaffold-coverage.yaml 2>/dev/null || true

# Clean all artifacts
clean:
	@echo "🧹 Uninstall Deployment and delete kind cluster..."
	chmod +x infra/teardown.sh && ./infra/teardown.sh
