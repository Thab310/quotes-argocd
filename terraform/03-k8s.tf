data "vault_generic_secret" "github_ssh_key" {
  path = "secret/github_ssh_key"
}

data "vault_generic_secret" "argocd-notifications-secret" {
  path = "secret/argocd-notifications-secret"
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
    url           = "git@github.com:Thab310/quotes-infrastructure.git"
    sshPrivateKey = data.vault_generic_secret.github_ssh_key.data["gh_ssh_private_key"]
    insecure      = false
    enableLfs     = false
  }
}

resource "kubernetes_secret" "slack_bot_token" {
  metadata {
    name      = "argocd-notifications-secret" #This is the name that is always given
    namespace = "argo-cd"
  }

  data = {
    slack-token = data.vault_generic_secret.argocd-notifications-secret.data["slack-token"]
  }
}
