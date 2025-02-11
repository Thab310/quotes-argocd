# Introduction to ArgoCD

## Prerequisites
* WSL
* Minikube
* Kubectl
* Helm
* Kustomize
* ArgoCD
* HashiCorp Vault

## What is ArgoCD?
ArgoCD is a GitOps or Continous Delivery(CD) tool that ensures that the git state remains synchronized with the K8s state.

## Architecture
![architecture](/images/Untitled-2025-02-10-0022.png)
## Project Structure
I decided to split the project into 3 different repos [Frontend](https://github.com/Thab310/frontend), [Backend](https://github.com/Thab310/quotes-backend) and [K8s Infrastructure](https://github.com/Thab310/quotes-infrastructure).

- Both [Frontend](https://github.com/Thab310/frontend) and [Backend](https://github.com/Thab310/quotes-backend) repositories make up the the CI phase of this GitOps poject. They Build Test and Deploy Artifacts to Docker Hub.
- [K8s Infrastructure](https://github.com/Thab310/quotes-infrastructure) repository stores the K8s manifest.
- We have the ArgoCD application deployed on MiniKube within my local cluster. It is responsible for Checking new images on for both frontend and backend applications. If there are any new images pushed ArgoCD will commit the - [K8s Infrastructure](https://github.com/Thab310/quotes-infrastructure) repo and then detect a drift between the k8s environment and the manifest files and then update the deployed kubernetes environment to match the state in the - [K8s Infrastructure](https://github.com/Thab310/quotes-infrastructure) repository
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

### Github SSH Keys
The ArgoCD Image Updater needs write access to my [K8s Infrastructure repository](https://github.com/Thab310/quotes-infrastructure) in order to commit new images it retrieves from DockerHub hence I will generate a ssh key.
```bash
ssh-keygen -t ed25519 -C "argocd@thab310.com" -f ~/.ssh/argocd_ed25519
```
* Then upload the public key located at `~/.ssh/argocd_ed25519.pub` to [K8s Infrastructure repository](https://github.com/Thab310/quotes-infrastructure)

![pub-key](/images/gh-pub-key.png)

* The private key will be used ArgoCD in order to Authenticate with [K8s Infrastructure repository](https://github.com/Thab310/quotes-infrastructure)

### Create a Slack Application
[How to create a slack application](https://api.slack.com/docs/apps)
Follow the process and make sure to store the bot token safely because you will need to store it as a secret inside Hashicorp vault.

![slack-1](/images/slack-1.png)

![slack-2](/images/slack-2.png)

![slack-3](/images/slack-3.png)

![slack-4](/images/slack-4.png)

![slack-6](/images/slack-5.png)

Now create a channel "#alerts" under the workspace that has your slack bot. 
Invite the bot into the channel but tagging it in a message.

![slack-6](/images/slack-6.png)
### Create Hashicorp vault secrets
In this project I will be using Vault as my secret store.
```bash
vault server -dev
```
![node](/images/vault-start.png)

Copy & Paste this commad on another bash terminal
```bash
  $ export TF_VAR_vault_token='<Root-Token>'
```
To verify status of vault server run:
```bash
vault status
```

Retrive private ssh key:
```bash
cat ~/.ssh/argocd_ed25519 | tr -d '\n'
```

Add secrets in vault:
```bash
vault kv put secret/github_ssh_key \
  gh_ssh_private_key="-----BEGIN OPENSSH PRIVATE KEY-----\n...your_private_key...\n-----END OPENSSH PRIVATE KEY-----"
```

```bash
vault kv put secret/argocd-notifications-secret \
  slack-token="********"
```

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