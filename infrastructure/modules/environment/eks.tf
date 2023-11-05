resource "aws_eks_cluster" "main" {
  name     = var.eks.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.28"

  enabled_cluster_log_types = ["api"]

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
  }

  vpc_config {
    # The cluster can only be accessed via the bastion host
    endpoint_public_access  = false
    endpoint_private_access = true
    subnet_ids              = [aws_subnet.app_1.id, aws_subnet.app_2.id, aws_subnet.app_3.id]
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-node"
  node_role_arn   = aws_iam_role.eks_node_group.arn

  instance_types = var.eks.node_instance_types
  subnet_ids     = [aws_subnet.app_1.id, aws_subnet.app_2.id, aws_subnet.app_3.id]

  scaling_config {
    min_size     = var.eks.min_size
    max_size     = var.eks.max_size
    desired_size = var.eks.desired_size
  }

  update_config {
    max_unavailable = 3
  }

  # These tags are required for Cluster Autoscaler auto-discovery
  tags = {
    "k8s.io/cluster-autoscaler/enabled"                      = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.main.name}" = "owned"
  }

  lifecycle {
    ignore_changes = [
      # Since Cluster Autoscaler handles scaling, we don't want to trigger a change
      # when the desired size changes
      scaling_config[0].desired_size
    ]
  }
}


resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  addon_version = "v1.28.2-eksbuild.2"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  addon_version = "v1.15.3-eksbuild.1"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  addon_version = "v1.10.1-eksbuild.5"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [aws_eks_node_group.main]
}
