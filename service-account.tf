# create service account for tiller - server side of Helm
#
#
resource "kubernetes_service_account" "tiller" {
  automount_service_account_token = true

  metadata {
    name      = "tiller-service-account"
    namespace = "kube-system"
  }
}

# allow tiller do the stuff :)
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-cluster-rule"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    api_group = ""
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }
}

# service account for deploying app (cicd, e.g. circleci)
#
#
resource "kubernetes_service_account" "cicd" {
  automount_service_account_token = true

  metadata {
    name      = "cicd-service-account"
    namespace = "${kubernetes_namespace.app.metadata.0.name}"
  }

  image_pull_secret {
    name = "${kubernetes_secret.dockerhub_secret.metadata.0.name}"
  }
}


resource "kubernetes_role" "cicd" {
  metadata {
    name      = "cicd-role"
    namespace = "${kubernetes_service_account.cicd.metadata.0.namespace}"
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["deployments", "services", "replicasets", "pods", "jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "cicd" {
  metadata {
    name      = "cicd-cluster-rule"
    namespace = "${kubernetes_service_account.cicd.metadata.0.namespace}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${kubernetes_role.cicd.metadata.0.name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.cicd.metadata.0.name}"
    api_group = ""
    namespace = "${kubernetes_service_account.cicd.metadata.0.namespace}"
  }
}

locals {
  dockercfg = {
    "${var.docker_registry_url}" = {
      email    = "${var.docker_email}"
      username = "${var.docker_username}"
      password = "${var.docker_password}"
      auth = "${base64encode(format("%s:%s", var.docker_username, var.docker_password))}"
    }
  }
}

resource "kubernetes_secret" "dockerhub_secret" {
  metadata {
    name = "dockerhub-secret"
    namespace = "${kubernetes_namespace.app.metadata.0.name}"
  }

  data = {
    ".dockerconfigjson" = "${ jsonencode(local.dockercfg) }"
  }

  type = "kubernetes.io/dockerconfigjson"
}