#!/bin/bash
# teardown.sh - Destroys cluster and cleans up artifacts
NAMESPACE="onlineboutique"
RELEASE_NAME="onlineboutique"
KIND_CLUSTER_NAME="microservices-demo"
helm uninstall ${RELEASE_NAME} -n ${NAMESPACE}
kind delete cluster --name ${KIND_CLUSTER_NAME}
