#!/bin/bash
# Aggregates Go coverage data from all Go microservices
#!/usr/bin/env bash
set -e

ROOT_DIR=$(pwd)
COVERAGE_DIR="$ROOT_DIR/go-coverage"
# Go services in the microservices demo
SERVICES=("frontend" "shippingservice" "productcatalogservice" "checkoutservice")

echo "🚀 Starting Go coverage collection for microservices..."
echo "Services to test: ${SERVICES[*]}"

# Create results directory
mkdir -p "$COVERAGE_DIR/results"
rm -f "$COVERAGE_DIR/results/"*_coverage.out 2>/dev/null || true

# Navigate to microservices-demo-main directory
cd "$ROOT_DIR/microservices-demo-main"

for SERVICE in "${SERVICES[@]}"; do
  echo ""
  echo "🧪 Running coverage for $SERVICE ..."
  
  SERVICE_DIR="src/$SERVICE"
  if [ ! -d "$SERVICE_DIR" ]; then
    echo "❌ Service directory $SERVICE_DIR not found, skipping..."
    continue
  fi
  
  cd "$SERVICE_DIR"
  
  # Check if go.mod exists
  if [ ! -f "go.mod" ]; then
    echo "❌ No go.mod found in $SERVICE_DIR, skipping..."
    cd "$ROOT_DIR/microservices-demo-main"
    continue
  fi
  
  # Run tests with coverage
  echo "   Running: go test ./... -coverprofile=coverage.out -covermode=atomic"
  if go test ./... -coverprofile=coverage.out -covermode=atomic; then
    if [ -f "coverage.out" ]; then
      mv coverage.out "$COVERAGE_DIR/results/${SERVICE}_coverage.out"
      echo "✅ Coverage data collected for $SERVICE"
    else
      echo "⚠️  No coverage data generated for $SERVICE (no tests or no coverage)"
    fi
  else
    echo "❌ Tests failed for $SERVICE"
  fi
  
  cd "$ROOT_DIR/microservices-demo-main"
done

echo ""
echo "📊 Processing coverage results..."
cd "$COVERAGE_DIR/results"

# Check if we have any coverage files
if ! ls *_coverage.out 1> /dev/null 2>&1; then
  echo "❌ No coverage files found. Make sure the services have tests."
  exit 1
fi

# Merge coverage files
echo "mode: atomic" > combined_coverage.out
for file in *_coverage.out; do
  if [ "$file" != "combined_coverage.out" ]; then
    grep -h -v "mode:" "$file" >> combined_coverage.out
  fi
done

echo ""
echo "📈 Coverage Summary:"
echo "===================="
cd "$COVERAGE_DIR"
go tool cover -func=results/combined_coverage.out

echo ""
echo "📊 Generating HTML report..."
go tool cover -html=results/combined_coverage.out -o results/combined_coverage.html

echo ""
echo "✅ Coverage collection complete!"
echo "📁 Combined coverage report: $COVERAGE_DIR/results/combined_coverage.html"
echo "📁 Individual service coverage files: $COVERAGE_DIR/results/"

# Generate summary for each service
echo ""
echo "📋 Individual Service Coverage:"
echo "==============================="
for SERVICE in "${SERVICES[@]}"; do
  coverage_file="results/${SERVICE}_coverage.out"
  if [ -f "$coverage_file" ]; then
    echo "🔹 $SERVICE:"
    go tool cover -func="$coverage_file" | tail -1
  fi
done
