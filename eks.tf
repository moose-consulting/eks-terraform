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

resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "local_file" "ssh" {
    sensitive_content = tls_private_key.ssh.private_key_pem
    filename = "${path.root}/.ssh/${terraform.workspace}.pem"
    file_permission = "0400"
}

resource "aws_key_pair" "eks" {
  key_name   = "eks-${terraform.workspace}"
  public_key = tls_private_key.ssh.public_key_openssh 
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
  subnet_ids      = [aws_subnet.cluster[0].id]
  instance_types  = [var.worker_instance_type]

  scaling_config {
    desired_size = var.n_workers
    max_size     = var.n_workers
    min_size     = var.n_workers
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.eks.key_name
  }

  tags = {
    Name        = "eks-${terraform.workspace}"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}
