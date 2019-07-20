# initialize Helm provider
provider "helm" {
  # version = "~> 0.7.0"

  install_tiller  = true
  service_account = "${kubernetes_service_account.tiller.metadata.0.name}"
  namespace       = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"

  debug = true

  kubernetes {
    host                   = "${digitalocean_kubernetes_cluster.project_digital_ocean_cluster.endpoint}"
    client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.project_digital_ocean_cluster.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(digitalocean_kubernetes_cluster.project_digital_ocean_cluster.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.project_digital_ocean_cluster.kube_config.0.cluster_ca_certificate)}"
  }
}


# Terraform official: https://www.terraform.io/docs/providers/helm/repository.html
data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}