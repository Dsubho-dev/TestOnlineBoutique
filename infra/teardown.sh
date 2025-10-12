#!/bin/bash
# teardown.sh - Destroys cluster and cleans up
NAMESPACE="onlineboutique"
RELEASE_NAME="onlineboutique"
helm uninstall ${RELEASE_NAME} -n ${NAMESPACE}
