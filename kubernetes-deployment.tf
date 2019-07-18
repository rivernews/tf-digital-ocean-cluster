

resource "kubernetes_deployment" "app" {
  metadata {
    name = "${var.app_name}-deployment"
    namespace = "${kubernetes_service_account.cicd.metadata.0.namespace}"
    labels = {
      app = "${var.app_label}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "${var.app_label}"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.app_label}"
        }
      }

      spec {
        # automount_service_account_token = true

        service_account_name = "${kubernetes_service_account.cicd.metadata.0.name}"

        image_pull_secrets {
            name = "${kubernetes_secret.dockerhub_secret.metadata.0.name}"
        }

        container {
            name  = "${var.app_name}"
            image = "${var.app_container_image}"

            # terraform official doc: https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#image_pull_policy
            # private image registry: https://stackoverflow.com/questions/49639280/kubernetes-cannot-pull-image-from-private-docker-image-repository
            image_pull_policy = "Always"

            port {
                container_port = "${var.app_exposed_port}"
            }

        #   resources {
        #     limits {
        #       cpu    = "0.5"
        #       memory = "512Mi"
        #     }
        #     requests {
        #       cpu    = "250m"
        #       memory = "50Mi"
        #     }
        #   }

        #   liveness_probe {
        #     http_get {
        #       path = "/nginx_status"
        #       port = 80

        #       http_header {
        #         name  = "X-Custom-Header"
        #         value = "Awesome"
        #       }
        #     }

        #     initial_delay_seconds = 3
        #     period_seconds        = 3
        #   }
        }
      }
    }
  }
}
