# code based: https://medium.com/@stepanvrany/terraforming-dok8s-helm-and-traefik-included-7ac42b5543dc
# Terraform official: helm_release - an instance of a chart running in a Kubernetes cluster. A Chart is a Helm package
# https://www.terraform.io/docs/providers/helm/release.html
# `helm_release` is similar to `helm install ...`
resource "helm_release" "project-nginx-ingress" {
  name = "nginx-ingress"

  # or chart = "stable/nginx-ingress"
  # see https://github.com/digitalocean/digitalocean-cloud-controller-manager/issues/162

  repository = "${data.helm_repository.stable.metadata.0.name}"
  chart      = "nginx-ingress"

  # helm chart values (equivalent to yaml)
  # https://github.com/terraform-providers/terraform-provider-helm/issues/145

  # `set` below refer to SO answer
  # https://stackoverflow.com/a/55968709/9814131

  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  set {
    name  = "controller.hostNetwork"
    value = true
  }

  set {
    name  = "controller.dnsPolicy"
    value = "ClusterFirstWithHostNet"
  }

  set {
    name  = "controller.daemonset.useHostPort"
    value = true
  }

  set {
    name  = "controller.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "rbac.create"
    value = true
  }

  depends_on = [
    "kubernetes_cluster_role_binding.tiller",
    "kubernetes_service_account.tiller"
  ]
}

resource "digitalocean_firewall" "project-cluster-firewall" {
  name = "project-cluster-firewall"
  tags = ["${digitalocean_tag.project-cluster.id}"]

  # Allow healthcheck
  inbound_rule {
    protocol   = "tcp"
    port_range = "80"

    # source_addresses   = ["0.0.0.0/0", "::/0"]
    source_tags = ["${digitalocean_tag.project-cluster.id}"]
  }

  # Allow load balancer traffic / tcp
  inbound_rule {
    protocol   = "tcp"
    port_range = "443"

    source_tags = ["${digitalocean_tag.project-cluster.id}"]
  }
}

# based on SO answer: https://stackoverflow.com/a/55968709/9814131
# TODO:
resource "helm_release" "project-external-dns" {
  name  = "external-dns"
  chart = "stable/external-dns"

  set {
    name  = "provider.<digitalocean -> aws_route53?>"
    value = true
  }

  set {
    name  = "<digitalocean -> aws_route53?>.<apiToken>"
    value = true
  }

  set {
    # domains you want external-dns to be able to edit
    name  = "domainFilters.create"
    value = "shaungc.com"
  }

  set {
    name  = "rbac.create"
    value = true
  }

  depends_on = [
    "kubernetes_cluster_role_binding.tiller",
    "kubernetes_service_account.tiller"
  ]
}

# template copied from terraform official doc: https://www.terraform.io/docs/providers/kubernetes/r/ingress.html
# modified based on SO answer: https://stackoverflow.com/a/55968709/9814131
resource "kubernetes_ingress" "example_ingress" {
  metadata {
    name = "project-ingress"
  }

  spec {
    backend {
      service_name = "MyApp1"
      service_port = 8080
    }

    rule {
      http {
        path {
          backend {
            service_name = "MyApp1"
            service_port = 8080
          }

          path = "/app1/*"
        }

        path {
          backend {
            service_name = "MyApp2"
            service_port = 8080
          }

          path = "/app2/*"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }
}