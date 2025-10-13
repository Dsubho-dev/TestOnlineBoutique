#!/bin/bash
# Adds coverage flags to Go services for instrumented builds
#!/usr/bin/env bash
set -e

ROOT_DIR=$(pwd)
SERVICES=("frontend" "shippingservice" "productcatalogservice" "checkoutservice")

echo "🔧 Enabling coverage instrumentation for Go services..."

# Navigate to microservices-demo-main directory
cd "$ROOT_DIR/microservices-demo-main"

for SERVICE in "${SERVICES[@]}"; do
  echo ""
  echo "🔧 Configuring coverage for $SERVICE..."
  
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
  
  # Create coverage-enabled Dockerfile
  if [ -f "Dockerfile" ]; then
    echo "   Creating Dockerfile.coverage for instrumented builds..."
    
    # Create a coverage-enabled version of the Dockerfile
    cp Dockerfile Dockerfile.coverage
    
    # Add coverage build flags to the Go build command
    sed -i 's/RUN go build -ldflags/RUN go build -cover -ldflags/' Dockerfile.coverage 2>/dev/null || true
    sed -i 's/RUN CGO_ENABLED=0 go build/RUN CGO_ENABLED=0 go build -cover/' Dockerfile.coverage 2>/dev/null || true
    
    # Add coverage environment variable
    sed -i '/ENV PORT/a ENV GOCOVERDIR=/tmp/coverage' Dockerfile.coverage 2>/dev/null || true
    
    # Create coverage directory in container
    sed -i '/WORKDIR/a RUN mkdir -p /tmp/coverage' Dockerfile.coverage 2>/dev/null || true
    
    echo "✅ Created Dockerfile.coverage for $SERVICE"
  else
    echo "⚠️  No Dockerfile found for $SERVICE"
  fi
  
  cd "$ROOT_DIR/microservices-demo-main"
done

echo ""
echo "🔧 Creating skaffold configuration for coverage builds..."

# Create a coverage-specific skaffold configuration
if [ -f "skaffold.yaml" ]; then
  cp skaffold.yaml skaffold-coverage.yaml
  
  # Update the skaffold file to use coverage Dockerfiles
  for SERVICE in "${SERVICES[@]}"; do
    sed -i "s|context: src/$SERVICE|context: src/$SERVICE\n    docker:\n      dockerfile: Dockerfile.coverage|g" skaffold-coverage.yaml 2>/dev/null || true
  done
  
  echo "✅ Created skaffold-coverage.yaml for instrumented builds"
fi

echo ""
echo "✅ Coverage instrumentation setup complete!"
echo "🚀 To build with coverage instrumentation:"
echo "   skaffold build -f skaffold-coverage.yaml"
echo ""
echo "🧪 To collect coverage from running containers:"
echo "   Use the collect_coverage.sh script or kubectl to copy coverage files from /tmp/coverage"
