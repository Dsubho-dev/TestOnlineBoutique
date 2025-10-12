#!/bin/bash
# Aggregates Go coverage data
#!/usr/bin/env bash
set -e

ROOT_DIR=$(pwd)
COVERAGE_DIR="$ROOT_DIR/go-coverage"
SERVICES=("emailservice" "paymentservice" "checkoutservice")

mkdir -p "$COVERAGE_DIR/results"

for SERVICE in "${SERVICES[@]}"; do
  echo "🧪 Running coverage for $SERVICE ..."
  cd "$ROOT_DIR/src/$SERVICE"
  go test ./... -coverprofile="$COVERAGE_DIR/results/${SERVICE}_coverage.out" -covermode=atomic
done

echo "📊 Merging coverage files ..."
cd "$COVERAGE_DIR/results"
echo "mode: atomic" > combined_coverage.out
grep -h -v "mode:" *_coverage.out >> combined_coverage.out

cd "$COVERAGE_DIR"
go tool cover -func=results/combined_coverage.out
go tool cover -html=results/combined_coverage.out -o results/combined_coverage.html

echo "✅ Combined coverage report generated: go-coverage/results/combined_coverage.html"
