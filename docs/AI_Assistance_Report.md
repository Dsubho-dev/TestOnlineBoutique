# AI Assistance Report

# Debugging HTTP/2 Test Failures in Online Boutique with ChatGPT

## Problem Summary

While running Pytest API tests for the **Online Boutique** microservices application, the tests failed with the error:

```bash
An HTTP/1.x request was sent to an HTTP/2 only endpoint.
```


This indicated that the tests were sending HTTP/1.x requests to services that only supported HTTP/2 over TLS (HTTPS), which is typical for gRPC-based services.

---

## Root Cause Analysis (Guided by ChatGPT)

ChatGPT explained that:

- The cartservice, checkoutservice, and other backend services are gRPC-only and do not accept HTTP/1.x or plain HTTP/2 requests.
- The `httpx` client cannot communicate over HTTP/2 without TLS unless the service supports h2c (rare).
- The test endpoints (for example, `http://localhost:7070`) were using plain HTTP, not HTTPS.

---

## ChatGPT Recommendations

### 1. Verify gRPC vs HTTP endpoints

ChatGPT first asked to check the Kubernetes service list using:

```bash
kubectl get svc -n onlineboutique
```

This confirmed that all backend services (cartservice, checkoutservice, etc.) were of type ClusterIP, meaning they are internal-only gRPC endpoints.

### 2. Introduce an Envoy proxy

ChatGPT suggested deploying Envoy as a local proxy to bridge HTTP/1.1 to HTTP/2 (gRPC).
It provided:

1. A working Envoy ConfigMap

1. Deployment YAML for the proxy

1. Debug steps for CrashLoopBackOff issues

### 3. Redirecting test traffic

ChatGPT explained that Pytest REST API tests should not call gRPC microservices directly.
Instead, traffic should go to the frontend service, which exposes REST-compatible endpoints.

A new port-forward was suggested:

```bash
kubectl port-forward svc/frontend -n onlineboutique 8081:80
```

Then, the endpoints fixture in the tests was updated to:

```bash
"cart": "http://localhost:8081/cart",
"checkout": "http://localhost:8081/cart/checkout",
"catalog": "http://localhost:8081/product",
```


## Helpful Prompts Used

Here are the key prompts that guided ChatGPT to respond effectively:

- pytest tests/api/test_cart_api.py (shared with logs)

- kubectl get svc -n onlineboutique

- send me the ConfigMap and Pod for Envoy with configuration pasted as required

- while deploying the envoy pod I see that it is in crashloopbackoff state.

- this is the error: Didn't find a registered implementation for 'envoy.filters.http.router'

These structured, incremental prompts helped ChatGPT understand both the infrastructure and test-level contexts, enabling full-stack debugging assistance.

# Test Automation Framework for Kubernetes Applications — Conversation Summary

## Problem Summary

This conversation focused on designing and implementing a **complete test automation framework** for the `microservices-demo` (Google Online Boutique) application, deployable on a **Kubernetes KIND cluster** with integrated **test coverage** for both Go services and automated UI/API testing.

---

## Key Deliverables Discussed

1. **Infrastructure Setup**
   - KIND cluster provisioning with Helm-based deployment.
   - Infrastructure-as-code created in the `infra/` directory.
   - Kubernetes manifests and Helm chart references for each service.
   - Support for environment provisioning and teardown.

2. **Test Automation Framework**
   - Implemented using **Pytest** + **Requests** for API tests.
   - **Selenium + Pytest** for UI automation (headless Chrome).
   - Modular test structure using **page object model (POM)**.
   - Data-driven and parameterized test handling.

3. **Go Coverage Automation**
   - `go-coverage/` directory added to handle Go microservice coverage.
   - Includes Dockerfile, Makefile, shell automation, and README.
   - Ability to collect per-service and combined coverage reports.
   - Supports coverage merging and HTML visualization.

4. **Makefile Integration**
   - Makefile used as a single command interface for:
     - Environment setup
     - Test execution (UI, API, Go)
     - Coverage report generation
   - Example:
     ```bash
     make test
     make go-coverage
     make report
     ```

5. **AI-Assisted Workflow**
   - ChatGPT (GPT-5) was used to assist in designing directory structure, writing test scripts, and generating infra and coverage automation.
   - Detailed prompts guided the AI to produce optimized, maintainable, and production-grade code.

## Helpful Promps Used

The following prompts were instrumental in structuring and refining the automation solution.
Each prompt was crafted to help ChatGPT generate focused, production-grade code and documentation.

| Prompt                                                                                                                                                               | Purpose                                                        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `Project: Test Automation for Kubernetes Applications ...`                                                                                                           | Initial project requirements dump to generate base repo design |
| `Can you provide me the code and content for infra directory`                                                                                           | To generate complete infrastructure-as-code setup              |
| `Now show me the code for test directory`                                                                                                                            | To generate test automation framework for API and UI tests     |
| `there was no test/ui/conftest.py file in directory structure`                                                                                                       | To clarify framework structure and improve design consistency  |
| `show option B all files in ui directory contents`                                                                                                                   | To finalize Page Object Model with conftest integration        |
| `add test for checkout`                                                                                                                                              | To extend test coverage with checkout flow validation          |
| `lets now work on go-coverage directory and see the content of files`                                                                                                | To add Go test coverage automation and reports                 |



