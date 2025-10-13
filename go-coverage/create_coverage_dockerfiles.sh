#!/bin/bash
# Creates coverage-enabled Dockerfiles for Go services
#!/usr/bin/env bash
set -e

ROOT_DIR=$(pwd)
SERVICES=("frontend" "shippingservice" "productcatalogservice" "checkoutservice")

echo "🐳 Creating coverage-enabled Dockerfiles for Go services..."

# Navigate to microservices-demo-main directory
cd "$ROOT_DIR/microservices-demo-main"

for SERVICE in "${SERVICES[@]}"; do
  echo ""
  echo "🔧 Creating Dockerfile.coverage for $SERVICE..."
  
  SERVICE_DIR="src/$SERVICE"
  if [ ! -d "$SERVICE_DIR" ]; then
    echo "❌ Service directory $SERVICE_DIR not found, skipping..."
    continue
  fi
  
  cd "$SERVICE_DIR"
  
  if [ ! -f "Dockerfile" ]; then
    echo "❌ No Dockerfile found for $SERVICE, skipping..."
    cd "$ROOT_DIR/microservices-demo-main"
    continue
  fi
  
  # Create coverage-enabled Dockerfile
  cat > Dockerfile.coverage << 'EOF'
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM --platform=$BUILDPLATFORM golang:1.23.4-alpine@sha256:c23339199a08b0e12032856908589a6d41a0dab141b8b3b21f156fc571a3f1d3 AS builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /src

# restore dependencies
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# Skaffold passes in debug-oriented compiler flags
ARG SKAFFOLD_GO_GCFLAGS

# Build with coverage instrumentation
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build \
    -cover \
    -gcflags="${SKAFFOLD_GO_GCFLAGS}" \
    -ldflags="-w -s -extldflags '-static'" \
    -a -installsuffix cgo \
    -o /go/bin/server .

FROM alpine AS without-grpc-health-probe-bin
RUN apk add --no-cache ca-certificates
WORKDIR /root/

# Copy the binary with coverage instrumentation
COPY --from=builder /go/bin/server /server

# Create directory for coverage data
RUN mkdir -p /tmp/coverage
ENV GOCOVERDIR=/tmp/coverage

EXPOSE 8080
ENTRYPOINT ["/server"]
EOF

  echo "✅ Created Dockerfile.coverage for $SERVICE"
  cd "$ROOT_DIR/microservices-demo-main"
done

echo ""
echo "✅ Coverage-enabled Dockerfiles created successfully!"
echo "🚀 To build with coverage: docker build -f Dockerfile.coverage -t service:coverage ."
