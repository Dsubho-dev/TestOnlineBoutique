#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="microservices-demo"
CONFIG_FILE="infra/kind-cluster.yaml"
NAMESPACE="onlineboutique"

echo "🚀 Creating Kind cluster '${CLUSTER_NAME}'..."
kind create cluster --name ${CLUSTER_NAME} --config ${CONFIG_FILE}

echo "📦 Deploying Google Cloud microservices-demo..."
helm upgrade onlineboutique oci://us-docker.pkg.dev/online-boutique-ci/charts/onlineboutique --install --create-namespace -n ${NAMESPACE}

echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment --all -n ${NAMESPACE} || true

echo "✅ Cluster and demo app are ready!"
kubectl get pods -n ${NAMESPACE}
kubectl get svc -n ${NAMESPACE}

echo "Deploy envoy"


kubectl port-forward deployment/frontend 8080:8080 -n ${NAMESPACE} &
echo "🌐 Access the demo app at http://localhost:8080"
