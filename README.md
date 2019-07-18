## Pitfalls

### Terraform
- Have to use `.id` for tags, otherwise if only "dot" to the resource name, it's the whole resource which cannot be used for specifying a tag. You either use `.name` or `.id`. The Medium post uses `.id`.
- When Terraform error, you have two choice as below. Remember that Terraform will keep all successfully created resources in track and won't re-create them next time (assume that you make no changes)
    - Use `terraform apply` to continue working on the rest of the provisioning.
    - Use `terraform destroy` to undo all created resources.

### `kubectl`
- `--kubeconfig`. ([K8 official](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/))

## Requirements

- DO's official K8 managing command line tool `brew install doctl`
- K8's official command line tool `brew install kubernetes-cli`

---

This repo is kick-started from [this post](https://ponderosa.io/blog/kubernetes/2019/03/13/terraform-cluster-create/), also the post for the upstream github repo.

# README

This cluster contains Terraform config to create a Kubernetes cluster on Digital Ocean and a shell script that gets a kubeconfig for accessing that cluster.

It assumes you have a Digital Ocean token ([here's how to get one](https://www.digitalocean.com/docs/api/create-personal-access-token/)).

## How to run

```
$ git clone git@github.com:ponderosa-io/tf-digital-ocean-cluster.git
$ export TF_VAR_do_token=<your_digital_ocean_token>
$ export TF_VAR_do_cluster_name=<your_cluster_name>
$ cd tf-digital-ocean-cluster
$ terraform plan
$ terraform apply
$ ./get_config
$ export KUBECONFIG=$(pwd)/config
```

