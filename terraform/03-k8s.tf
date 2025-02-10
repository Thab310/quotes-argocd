data "vault_generic_secret" "github_ssh_key" {
  path = "secret/github_ssh_key"
}

resource "kubernetes_secret" "github_secret" {
  metadata {
    name      = "github-ssh-key"
    namespace = "argo-cd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    url             = "ssh://github.com/Thab310/quotes-infrastructure.git"
    ssh_private_key = data.vault_generic_secret.github_ssh_key.data["gh_ssh_private_key"]
    insecure        = false
    enableLfs       = false
  }
}