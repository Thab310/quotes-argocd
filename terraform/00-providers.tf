provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" #local path to kubeconfig file 
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = var.vault_token
}
