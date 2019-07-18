# https://www.terraform.io/docs/configuration/variables.html#variable-definitions-tfvars-files

variable "do_token" {}
variable "do_username" {}
variable "do_password" {}
variable "docker_registry_url" {}

variable "docker_email" {}
variable "docker_username" {}
variable "docker_password" {}


variable "do_cluster_name" {}

variable "app_container_image" {}

variable "app_namespace" {}

variable "app_label" {}

variable "app_name" {}

variable "app_exposed_port" {}
