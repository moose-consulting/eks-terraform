# eks-terraform

Simply provision an EKS cluster with Terraform

* Configures a multi-zone EKS cluster with one node group as described by [AWS Getting Started Guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html).
* Simple configuration with just a few veriables.
* Manage multiple clusters with Terraform workspaces.

# Variables

`region`: The AWS region to deploy cluster to (e.g. "eu-west-1").

`n_workers`: Number of workers in cluster node group.

`worker_instance_type`: Instance type to use for cluster node group (e.g. "t3.medium").

# Usage

### Deploy Cluster

1. Set AWS credential environment variables for Terraform AWS provider:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
2. Run `terraform init` to install AWS provider.
3. Apply Terraform plan:

```
TF_VAR_region=eu-west-1 TF_VAR_n_workers=1 TF_VAR_worker_instance_type=t3.medium terraform apply
```

4. To manage cluster, you need `awscli` and `kubectl`:

```
aws eks --region eu-west-1 update-kubeconfig --name eks-$(terraform workspace show)
kubectl get nodes
```

### Destroy Cluster

```
TF_VAR_region=eu-west-1 TF_VAR_n_workers=1 TF_VAR_worker_instance_type=t3.medium terraform destroy
```
