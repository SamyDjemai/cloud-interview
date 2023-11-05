data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ssm" {
  name        = "AmazonSSMManagedInstanceCore"
  description = "Allows EC2 access through SSM"

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

resource "aws_iam_instance_profile" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
  role = aws_iam_role.ssm.name
}

resource "aws_iam_role" "eks_cluster" {
  name        = "eksClusterRole"
  description = "Allows access to other AWS service resources that are required to operate clusters managed by EKS."

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "eks.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLocalOutpostClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]
}

resource "aws_iam_role" "eks_node_group" {
  name        = "eksNodeGroupRole"
  description = "Allows EC2 instances to call AWS services on your behalf."

  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSLocalOutpostClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ]
}

resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name = "AWSEKSClusterAutoscaler"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled" : "true",
              "aws:ResourceTag/k8s.io/cluster-autoscaler/${aws_eks_cluster.main.name}" : "owned"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeScalingActivities",
            "ec2:DescribeLaunchTemplateVersions",
            "autoscaling:DescribeTags",
            "autoscaling:DescribeLaunchConfigurations",
            "ec2:DescribeInstanceTypes"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

# __generated__ by Terraform from "AWSEKSClusterAutoscaler"
resource "aws_iam_role" "eks_cluster_autoscaler" {
  name = "AWSEKSClusterAutoscaler"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
          },
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Condition" : {
            "StringEquals" : {
              "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:cluster-autoscaler",
              "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" : "sts.amazonaws.com"
            }
          }
        }
      ]
    }
  )

  managed_policy_arns = [aws_iam_policy.eks_cluster_autoscaler.arn]
}
