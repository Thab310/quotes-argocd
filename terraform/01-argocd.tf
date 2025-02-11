resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm" #helm repo list
  chart            = "argo-cd"
  create_namespace = true
  namespace        = "argo-cd"
  version          = "7.8.2" #To get the chart version "helm search repo argocd"
  values           = [file("values/argo-cd.yaml")]
}