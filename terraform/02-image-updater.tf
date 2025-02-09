resource "helm_release" "updater" {
  name = "updater"

  repository       = "https://argoproj.github.io/argo-helm" #helm repo list
  chart            = "argocd-image-updater"
  namespace        = "argo-cd"
  create_namespace = true
  version          = " 0.12.0" #To get the chart version "helm search repo updater"
  values           = [file("values/image-updater.yaml")]
}