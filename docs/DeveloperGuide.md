# Developer Guide: Microservice App Installation & Access

This guide will walk you through setting up a microservice application using Docker, Kind, and Helm for local development and testing. This guide also showcases automated way of deploying and teardown.

## Prerequisites

Before starting, ensure you have the following tools installed:

### Required Tools

1. **Docker Desktop**
   - **Windows**: Download and install from: [https://docs.docker.com/desktop/install/windows-install/](https://docs.docker.com/desktop/install/windows-install/)
   - **Linux**: 
     - Ubuntu/Debian: [https://docs.docker.com/desktop/install/ubuntu/](https://docs.docker.com/desktop/install/ubuntu/)
     - Or install Docker Engine: [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
     - Fedora/RHEL: [https://docs.docker.com/engine/install/fedora/](https://docs.docker.com/engine/install/fedora/)
   - Ensure Docker is running before proceeding

2. **Kind CLI (Kubernetes in Docker)**
   - Installation guide: [https://kind.sigs.k8s.io/docs/user/quick-start/#installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
   - **Windows**: Use chocolatey `choco install kind` or download binary
   - **Linux**: 
     ```bash
     # Download and install Kind
     curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
     chmod +x ./kind
     sudo mv ./kind /usr/local/bin/kind
     ```

3. **Helm**
   - Installation guide: [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)
   - **Windows**: Use chocolatey `choco install kubernetes-helm` or download binary
   - **Linux**:
     ```bash
     # Using script
     curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
     
     # Or using package manager (Ubuntu/Debian)
     curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
     sudo apt-get update
     sudo apt-get install helm
     ```

4. **kubectl** (usually comes with Docker Desktop)
   - **Windows**: Installation guide: [https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
   - **Linux**: 
     ```bash
     # Download and install kubectl
     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
     chmod +x kubectl
     sudo mv kubectl /usr/local/bin/
     
     # Or using package manager (Ubuntu/Debian)
     sudo apt-get update
     sudo apt-get install -y apt-transport-https ca-certificates curl
     curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
     echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
     sudo apt-get update
     sudo apt-get install -y kubectl
     ```

## Setup Instructions (Manual)

### Step 1: Create Kind Cluster

Create a Kubernetes cluster using the provided configuration:

```bash
kind create cluster --config infra/kind-config.yaml
```

**Expected Output:**
```
Creating cluster "microservices-demo" ...
✓ Ensuring node image (kindest/node:v1.25.3) 🖼
✓ Preparing nodes 📦 📦
✓ Writing configuration 📜
✓ Starting control-plane 🕹️
✓ Installing CNI 🔌
✓ Installing StorageClass 💾
✓ Joining worker nodes 🚜
Set kubectl context to "kind-microservices-demo"
You can now use your cluster with:

kubectl cluster-info --context kind-microservices-demo
```

**Verify cluster nodes:**
```bash
kubectl get nodes
```

**Expected Output:**
```
NAME                               STATUS   ROLES           AGE     VERSION
microservices-demo-control-plane   Ready    control-plane   2m53s   v1.25.3
microservices-demo-worker          Ready    <none>          2m32s   v1.25.3
```

### Step 2: Install Application using Helm

Deploy the online boutique microservice application:

```bash
helm upgrade onlineboutique oci://us-docker.pkg.dev/online-boutique-ci/charts/onlineboutique --install
```

**Expected Output:**
```
Release "onlineboutique" does not exist. Installing it now.
Pulled: us-docker.pkg.dev/online-boutique-ci/charts/onlineboutique:0.10.3
Digest: sha256:f6961f1ee50a8477eeb2e1d4ee98353e7289e868ed1114a476cc92868582f3bd
NAME: onlineboutique
LAST DEPLOYED: Mon Oct 13 23:16:48 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

**Verify Pod Deployment:**

Wait for all pods to be in Running state:

```bash
kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-86dc87b7b5-s97kq               1/1     Running   0          20m
cartservice-c875689b7-v8w97              1/1     Running   0          20m
checkoutservice-99ff5f65-5bjfz           1/1     Running   0          20m
currencyservice-d5744f4bb-x9qmw          1/1     Running   0          20m
emailservice-567c779dc7-d5m4l            1/1     Running   0          20m
frontend-6cc5487698-7vh72                1/1     Running   0          20m
loadgenerator-7cb965d888-lb7jm           1/1     Running   0          20m
paymentservice-6777cbd844-pddph          1/1     Running   0          20m
productcatalogservice-6bcdc56f99-rj6x2   1/1     Running   0          20m
recommendationservice-7449686c69-b8cxt   1/1     Running   0          20m
redis-cart-5bff49f587-668dh              1/1     Running   0          20m
shippingservice-77d9d9989f-ltlfc         1/1     Running   0          20m
```

### Step 3: Deploy Envoy Proxy

Deploy the Envoy proxy for traffic management:

> **⚠️ Important:** Before applying, make sure the namespace is updated to the correct one in `envoy-proxy.yaml` (By default: `onlineboutique`)

```bash
kubectl apply -f infra/envoy-proxy.yaml
```

You should see the Envoy pod running successfully:

```bash
NAME                    READY   STATUS    RESTARTS   AGE
envoy-proxy-65c7c4c9b4   1/1     Running   0          30s
```

## Verification Steps

### Check Application Status

1. **Verify all services are running:**
   ```bash
   kubectl get svc -n onlineboutique
   	NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
	adservice               ClusterIP      10.96.11.88     <none>        9555/TCP            23m
	cartservice             ClusterIP      10.96.26.106    <none>        7070/TCP            23m
	checkoutservice         ClusterIP      10.96.41.44     <none>        5050/TCP            23m
	currencyservice         ClusterIP      10.96.78.26     <none>        7000/TCP            23m
	emailservice            ClusterIP      10.96.95.224    <none>        5000/TCP            23m
	envoy-proxy             ClusterIP      10.96.29.31     <none>        8080/TCP,9901/TCP   15m
	frontend                ClusterIP      10.96.189.84    <none>        80/TCP              23m
	frontend-external       LoadBalancer   10.96.178.57    <pending>     80:30285/TCP        23m
	kubernetes              ClusterIP      10.96.0.1       <none>        443/TCP             28m
	paymentservice          ClusterIP      10.96.230.188   <none>        50051/TCP           23m
	productcatalogservice   ClusterIP      10.96.139.98    <none>        3550/TCP            23m
	recommendationservice   ClusterIP      10.96.79.97     <none>        8080/TCP            23m
	redis-cart              ClusterIP      10.96.178.194   <none>        6379/TCP            23m
	shippingservice         ClusterIP      10.96.99.205    <none>        50051/TCP           23m

   ```

2. **Check pod logs if needed:**
   ```bash
   kubectl logs -n onlineboutique <pod-name>
   ```

### Cleanup (Optional)

To tear down the environment when done:

```bash
# Delete the Kind cluster
kind delete cluster --name microservices-demo
```

To uninstall the application and clean up all resources:

```bash
helm uninstall $release_name -n onlineboutique
```

## Setup Instructions (Automated)
### Automated Infra Setup
Deploy cluster, application and required services (envoy) to setup entire infrastructure with simple Makefile target

```bash
make setup
```

Expected output:
```bash
🚀 Setting up infrastructure...
chmod +x infra/setup.sh && ./infra/setup.sh
🚀 Creating Kind cluster 'microservices-demo'...
Creating cluster "microservices-demo" ...
 ✓ Ensuring node image (kindest/node:v1.25.3) 🖼
 ✓ Preparing nodes 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-microservices-demo"
You can now use your cluster with:

kubectl cluster-info --context kind-microservices-demo

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/
📦 Deploying Google Cloud microservices-demo...
Release "onlineboutique" does not exist. Installing it now.
Pulled: us-docker.pkg.dev/online-boutique-ci/charts/onlineboutique:0.10.3
Digest: sha256:f6961f1ee50a8477eeb2e1d4ee98353e7289e868ed1114a476cc92868582f3bd
NAME: onlineboutique
LAST DEPLOYED: Tue Oct 14 04:26:59 2025
NAMESPACE: onlineboutique
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Note: It may take a few minutes for the LoadBalancer IP to be available.

Watch the status of the frontend IP address with:
    kubectl get --namespace onlineboutique svc -w frontend-external

Get the external IP address of the frontend:
    export SERVICE_IP=$(kubectl get svc --namespace onlineboutique frontend-external --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
    echo http://$SERVICE_IP
⏳ Waiting for deployments to be ready...
deployment.apps/adservice condition met
deployment.apps/cartservice condition met
deployment.apps/checkoutservice condition met
deployment.apps/currencyservice condition met
deployment.apps/emailservice condition met
deployment.apps/frontend condition met
deployment.apps/loadgenerator condition met
deployment.apps/paymentservice condition met
deployment.apps/productcatalogservice condition met
deployment.apps/recommendationservice condition met
deployment.apps/redis-cart condition met
deployment.apps/shippingservice condition met
✅ Cluster and demo app are ready!
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-86dc87b7b5-46tks               1/1     Running   0          76s
cartservice-c875689b7-x9m7x              1/1     Running   0          76s
checkoutservice-99ff5f65-m55hg           1/1     Running   0          76s
currencyservice-d5744f4bb-jdm8c          1/1     Running   0          76s
emailservice-567c779dc7-wq857            1/1     Running   0          76s
frontend-6cc5487698-n7rb8                1/1     Running   0          76s
loadgenerator-7cb965d888-259wp           1/1     Running   0          76s
paymentservice-6777cbd844-4q6zf          1/1     Running   0          76s
productcatalogservice-6bcdc56f99-shgmj   1/1     Running   0          76s
recommendationservice-7449686c69-2prfl   1/1     Running   0          76s
redis-cart-5bff49f587-t9b7q              1/1     Running   0          76s
shippingservice-77d9d9989f-6kwzf         1/1     Running   0          76s
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
adservice               ClusterIP      10.96.203.114   <none>        9555/TCP       76s
cartservice             ClusterIP      10.96.202.33    <none>        7070/TCP       76s
checkoutservice         ClusterIP      10.96.101.104   <none>        5050/TCP       76s
currencyservice         ClusterIP      10.96.218.90    <none>        7000/TCP       76s
emailservice            ClusterIP      10.96.221.236   <none>        5000/TCP       76s
frontend                ClusterIP      10.96.15.162    <none>        80/TCP         76s
frontend-external       LoadBalancer   10.96.82.11     <pending>     80:31368/TCP   76s
paymentservice          ClusterIP      10.96.99.67     <none>        50051/TCP      76s
productcatalogservice   ClusterIP      10.96.163.147   <none>        3550/TCP       76s
recommendationservice   ClusterIP      10.96.202.65    <none>        8080/TCP       76s
redis-cart              ClusterIP      10.96.62.155    <none>        6379/TCP       76s
shippingservice         ClusterIP      10.96.180.158   <none>        50051/TCP      76s
📦Deploy envoy
✅ configmap/envoy-proxy-config created
✅ pod/envoy-proxy created
✅ service/envoy-proxy created
```

### Automated Infra Cleanup
Uninstall cluster, application and artifacts with Makefile target

```bash
make clean
```

## Next Steps

Once the environment is set up, you can:
- Port-forward the frontend service to access the application locally.

	```bash
	kubectl port-forward -n onlineboutique svc/frontend 8081:80
	```
- Access the app in your browser at: http://localhost:8081

- Run API or UI tests using pytest or Makefile targets.
