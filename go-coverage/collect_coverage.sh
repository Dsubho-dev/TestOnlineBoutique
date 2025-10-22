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

  # Run tests with coverage, excluding generated code patterns
  echo "   Running: go test ./... -coverprofile=coverage.out -covermode=atomic"
  
  # Try to run tests, but don't fail the entire script if some packages fail
  set +e  # Don't exit on error temporarily
  go test ./... -coverprofile=coverage.out -covermode=atomic 2>&1 | tee test_output.log
  test_result=$?
  set -e  # Re-enable exit on error
  
  if [ $test_result -eq 0 ]; then
    if [ -f "coverage.out" ]; then
      mv coverage.out "$COVERAGE_DIR/results/${SERVICE}_coverage.out"
      echo "✅ Coverage data collected for $SERVICE"
    else
      echo "⚠️  No coverage data generated for $SERVICE (no tests or no coverage)"
    fi
  else
    # Check if we have partial coverage even with some failures
    if [ -f "coverage.out" ]; then
      mv coverage.out "$COVERAGE_DIR/results/${SERVICE}_coverage.out"
      echo "⚠️  Tests had some failures for $SERVICE, but coverage data was collected"
    else
      echo "❌ Tests failed for $SERVICE and no coverage data was generated"
      # Try to get coverage for individual packages that do work
      echo "   Attempting package-by-package coverage collection..."
      
      # Get list of packages and test them individually
      for pkg in $(go list ./... 2>/dev/null | grep -v genproto || true); do
        pkg_name=$(basename "$pkg")
        echo "     Testing package: $pkg_name"
        if go test "$pkg" -coverprofile="${pkg_name}_coverage.out" -covermode=atomic 2>/dev/null; then
          if [ -f "${pkg_name}_coverage.out" ]; then
            cat "${pkg_name}_coverage.out" >> temp_combined.out
            rm "${pkg_name}_coverage.out"
          fi
        fi
      done
      
      if [ -f "temp_combined.out" ]; then
        mv temp_combined.out "$COVERAGE_DIR/results/${SERVICE}_coverage.out"
        echo "✅ Partial coverage data collected for $SERVICE"
      fi
    fi
  fi
  
  # Clean up
  rm -f test_output.log

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

# Merge coverage files, excluding genproto packages
echo "mode: atomic" > combined_coverage.out
for file in *_coverage.out; do
  if [ "$file" != "combined_coverage.out" ]; then
    # Filter out genproto lines which are generated code
    grep -h -v "mode:" "$file" | grep -v "/genproto/" >> combined_coverage.out 2>/dev/null || true
  fi
done

echo ""
echo "📈 Coverage Summary:"
echo "===================="

# Check if combined coverage file has content beyond the mode line
if [ $(wc -l < "$COVERAGE_DIR/results/combined_coverage.out") -gt 1 ]; then
  # Run go tool cover from within a Go module context (use the first service directory)
  cd "$ROOT_DIR/microservices-demo-main/src/checkoutservice"
  go tool cover -func="$COVERAGE_DIR/results/combined_coverage.out" 2>/dev/null || {
    echo "⚠️  Could not generate combined coverage summary (likely due to module path issues)"
    echo "✅ Individual service coverage data was collected successfully"
  }
else
  echo "⚠️  No coverage data to combine (only generated code found)"
fi

echo ""
echo "📊 Generating HTML report..."
if [ $(wc -l < "$COVERAGE_DIR/results/combined_coverage.out") -gt 1 ]; then
  # Run go tool cover from within a Go module context
  cd "$ROOT_DIR/microservices-demo-main/src/checkoutservice"
  go tool cover -html="$COVERAGE_DIR/results/combined_coverage.out" -o "$COVERAGE_DIR/results/combined_coverage.html" 2>/dev/null || {
    echo "⚠️  Could not generate combined HTML report due to module path issues"
    echo "📊 Generating individual HTML reports instead..."
    
    # Generate individual HTML reports for each service
    cd "$COVERAGE_DIR"
    for SERVICE in "${SERVICES[@]}"; do
      service_coverage="results/${SERVICE}_coverage.out"
      if [ -f "$service_coverage" ] && [ $(wc -l < "$service_coverage") -gt 1 ]; then
        cd "$ROOT_DIR/microservices-demo-main/src/$SERVICE"
        go tool cover -html="$COVERAGE_DIR/$service_coverage" -o "$COVERAGE_DIR/results/${SERVICE}_coverage.html" 2>/dev/null && {
          echo "✅ Generated HTML report for $SERVICE: results/${SERVICE}_coverage.html"
        } || {
          echo "⚠️  Could not generate HTML report for $SERVICE"
        }
        cd "$COVERAGE_DIR"
      fi
    done
  }
else
  echo "⚠️  Skipping HTML report generation (no meaningful coverage data)"
fi

echo ""
echo "✅ Coverage collection complete!"
if [ -f "$COVERAGE_DIR/results/combined_coverage.html" ]; then
  echo "📁 Combined coverage report: $COVERAGE_DIR/results/combined_coverage.html"
else
  echo "📁 Individual coverage reports available in: $COVERAGE_DIR/results/"
  for SERVICE in "${SERVICES[@]}"; do
    if [ -f "$COVERAGE_DIR/results/${SERVICE}_coverage.html" ]; then
      echo "   - ${SERVICE}_coverage.html"
    fi
  done
fi
echo "📁 Individual service coverage files: $COVERAGE_DIR/results/"

# Generate summary for each service
echo ""
echo "📋 Individual Service Coverage:"
echo "==============================="
cd "$COVERAGE_DIR"
for SERVICE in "${SERVICES[@]}"; do
  coverage_file="results/${SERVICE}_coverage.out"
  if [ -f "$coverage_file" ]; then
    echo "🔹 $SERVICE:"
    # Create a filtered version without genproto for summary
    filtered_file="results/${SERVICE}_filtered.out"
    head -1 "$coverage_file" > "$filtered_file"
    grep -v "/genproto/" "$coverage_file" | tail -n +2 >> "$filtered_file" 2>/dev/null || true
    
    if [ $(wc -l < "$filtered_file") -gt 1 ]; then
      # Run from the service directory for proper module context
      cd "$ROOT_DIR/microservices-demo-main/src/$SERVICE"
      go tool cover -func="$COVERAGE_DIR/$filtered_file" 2>/dev/null | tail -1 || echo "   No meaningful coverage data (likely only generated code)"
      cd "$COVERAGE_DIR"
    else
      echo "   No testable code found (only generated code)"
    fi
    rm -f "$filtered_file"
  else
    echo "🔹 $SERVICE: No coverage data found"
  fi
done
