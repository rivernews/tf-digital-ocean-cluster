# Get a Digital Ocean token from your Digital Ocean account
#   See: https://www.digitalocean.com/docs/api/create-personal-access-token/
# Set TF_VAR_do_token to use your Digital Ocean token automatically
provider "digitalocean" {
  token = "${var.do_token}"
}

# Terraform officials: https://www.terraform.io/docs/providers/do/r/tag.html
resource "digitalocean_tag" "project-cluster" {
  name = "project-cluster"
}

# Terraform official: https://www.terraform.io/docs/providers/do/d/kubernetes_cluster.html
resource "digitalocean_kubernetes_cluster" "project_digital_ocean_cluster" {
  name    = "${var.do_cluster_name}"
  region  = "sfo2"
  version = "1.14.3-do.0"

  node_pool {
    name       = "project-node-pool"
    size       = "s-1vcpu-2gb"
    node_count = 1
  }

  tags = ["${digitalocean_tag.project-cluster.id}"]
}

# https://medium.com/@stepanvrany/terraforming-dok8s-helm-and-traefik-included-7ac42b5543dc
#
#
resource "local_file" "kubeconfig" {
    content     = "${digitalocean_kubernetes_cluster.project_digital_ocean_cluster.kube_config.0.raw_config}"
    filename = "kubeconfig.yaml"
}

# initialize Kubernetes provider
provider "kubernetes" {
  host = "${digitalocean_kubernetes_cluster.project_digital_ocean_cluster.endpoint}"
  username = "${var.do_username}"
  password = "${var.do_password}"

  client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.project_digital_ocean_cluster.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(digitalocean_kubernetes_cluster.project_digital_ocean_cluster.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.project_digital_ocean_cluster.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "${var.app_namespace}"
  }
}