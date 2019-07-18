output "cluster-id" {
  value = "${digitalocean_kubernetes_cluster.project_digital_ocean_cluster.id}"
}

output "do_cluster_token_endpoint" {
  value = "${digitalocean_kubernetes_cluster.project_digital_ocean_cluster.endpoint}"
}

output "do_cluster_current_status" {
  value = "${digitalocean_kubernetes_cluster.project_digital_ocean_cluster.status}"
}