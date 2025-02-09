# Introduction to ArgoCD

## Prerequisites
* WSL
* Minikube
* Kubectl
* Helm
* Kustomize
* ArgoCD

## What is ArgoCD?
ArgoCD is a GitOps or Continous Delivery(CD) tool that ensures that the git state remains synchronized with the K8s state.

## Architecture
![architecture](/images/Untitled-2025-02-10-0022.png)

## Getting started
### 1. Make sure Docker hub is running

### 2. Set up k8s local environment
```bash
minikube start --kubernetes-version=v1.32.1 --driver=docker
```
- This command spins up a k8s cluster and enables it to run kubernetes nodes as docker containers

![minikube](/images/minikube-start.png)
![node](/images/minikube-node.png)

- Usually you cannot run pods on the master but minikube `removes the taints` from the master node because it uses 1 node as a both a `controller & worker node`.

### 3. Setup ArgoCD Helm repository
![node](/images/helm-repo.png)

### Installation of helm charts :)
![TIP]
 Instead of of using the traditional approach of installing helm charts using helm cli commands we will take a step further by using terraform and helm providers


```hcl
resource "helm_release" "argocd" {
  name             = "argocd"

  repository       = "https://argoproj.github.io/argo-helm" #helm repo list
  chart            = "argo-cd"
  create_namespace = true #Create ns if it does not exist in the cluster
  namespace        = "argo-cd"
  version          = "7.8.2" #To get the chart version "helm search repo argocd"
  values           = [ file("values/argocd.yaml") ]
}
```
To get the terraform specific helm release details run the helm commands below

![node](/images/default-values.png)

Apply terraform script
![node](/images/tf-apply.png)
Confirm installation of ArgoCD Helm chart in specified namespace.
![node](/images/applied-argo.png)
### Accessing ArgoCD dashboard
1. Retrieve ArgoCD password

![node](/images/argo-cd-pwd.png)
2. Access the dashboard on localhost port 8080. The `username` is `admi`n and `password` is contents of base64 decoded secret `argocd-initial-admin-secret` in ns `argo-cd`.

![node](/images/argo-dashboard.png)