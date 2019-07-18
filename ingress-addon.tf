
# Terraform official: https://www.terraform.io/docs/providers/helm/repository.html
data "helm_repository" "stable" {
    name = "stable"
    url  = "https://kubernetes-charts.storage.googleapis.com"
}

# code based: https://medium.com/@stepanvrany/terraforming-dok8s-helm-and-traefik-included-7ac42b5543dc
# Terraform official: helm_release - an instance of a chart running in a Kubernetes cluster. A Chart is a Helm package
# https://www.terraform.io/docs/providers/helm/release.html
resource "helm_release" "project-nginx-ingress" {
    name      = "nginx-ingress"
    repository = "${data.helm_repository.stable.metadata.0.name}"
    chart     = "nginx-ingress"

    # helm chart values (equivalent to yaml)
    # https://github.com/terraform-providers/terraform-provider-helm/issues/145

    set {
      name = "controller.kind"
      value = "DaemonSet"
    }

    set {
      name = "controller.hostNetwork"
      value = true
    }

    set {
      name = "controller.dnsPolicy"
      value = "ClusterFirstWithHostNet"
    }

    set {
      name = "controller.daemonset.useHostPort"
      value = true
    }

    set {
      name = "controller.service.type"
      value = "ClusterIP"
    }

    set {
      name = "rbac.create"
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
    protocol = "tcp"
    port_range = "80"

    # source_addresses   = ["0.0.0.0/0", "::/0"]
    source_tags = ["${digitalocean_tag.project-cluster.id}"]
  }

  # Allow load balancer traffic / tcp
  inbound_rule {
    protocol = "tcp"
    port_range = "443"

    source_tags = ["${digitalocean_tag.project-cluster.id}"]
  }
}