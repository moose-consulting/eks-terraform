resource "aws_eks_cluster" "cluster" {
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-service-policy,
  ]

  name     = "eks-${terraform.workspace}"
  role_arn = aws_iam_role.service-role.arn

  vpc_config {
    subnet_ids = aws_subnet.cluster.*.id
  }

  tags = {
    Name        = "eks-${terraform.workspace}"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}

resource "aws_eks_node_group" "cluster" {
  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-policy,
    aws_iam_role_policy_attachment.eks-cni-policy,
    aws_iam_role_policy_attachment.eks-ecr-policy,
  ]

  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "eks-${terraform.workspace}"
  node_role_arn   = aws_iam_role.node-role.arn
  subnet_ids      = aws_subnet.cluster.*.id
  instance_types  = [var.worker_instance_type]

  scaling_config {
    desired_size = var.n_workers
    max_size     = var.n_workers
    min_size     = var.n_workers
  }

  tags = {
    Name        = "eks-${terraform.workspace}"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}
