resource "kubernetes_service" "app" {
  metadata {
    name = "${var.app_name}-service"
    namespace = "${kubernetes_service_account.cicd.metadata.0.namespace}"
  }
  spec {
    type = "ClusterIP"
    
    selector = {
      app = "${kubernetes_deployment.app.metadata.0.labels.app}"
    }

    # session_affinity = "ClientIP"

    port {
      port        = 80 # incoming connection
      target_port = "${var.app_exposed_port}" # route to app
    }

  }
}

# resource "kubernetes_pod" "example" {
#   metadata {
#     name = "terraform-example"
#     labels = {
#       app = "MyApp"
#     }
#   }

#   spec {
#     container {
#       image = "nginx:1.7.9"
#       name  = "example"
#     }
#   }
# }