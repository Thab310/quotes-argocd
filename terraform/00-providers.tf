provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" #local path to kubeconfig file 
  }
}