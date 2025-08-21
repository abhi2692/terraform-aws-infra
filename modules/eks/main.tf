resource "aws_iam_role" "eks_cluster" {
  count = var.create_eks ? 1 : 0

  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  count      = var.create_eks ? 1 : 0
  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_VPCResourceController" {
  count      = var.create_eks ? 1 : 0
  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role" "eks_node" {
  count = var.create_eks ? 1 : 0

  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  count      = var.create_eks ? 1 : 0
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.create_eks ? 1 : 0
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  count      = var.create_eks ? 1 : 0
  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# OIDC Provider - enables IRSA for any addon or application
data "tls_certificate" "eks_oidc_root_ca" {
  count = var.create_eks ? 1 : 0
  url   = aws_eks_cluster.mycluster[0].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  count = var.create_eks ? 1 : 0
  
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc_root_ca[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.mycluster[0].identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-eks-oidc"
  }
}

resource "aws_eks_cluster" "mycluster" {

  count    = var.create_eks ? 1 : 0
  name     = var.cluster_name
  version  = var.kubernetes_version != null ? var.kubernetes_version : null
  role_arn = aws_iam_role.eks_cluster[0].arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  depends_on = [aws_iam_role.eks_cluster]
}

resource "aws_eks_node_group" "mynode_group" {

  count           = var.create_eks ? 1 : 0
  cluster_name    = aws_eks_cluster.mycluster[0].name
  version         = var.kubernetes_version != null ? var.kubernetes_version : null
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node[0].arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}
