# Create EKS I AM Role
resource "aws_iam_role" "eks-role" {
  name = "project-eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "project-eks-policy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-role.name
}

resource "aws_iam_role_policy_attachment" "project-eks-policy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-role.name
}

# Create EKS Cluster
resource "aws_eks_cluster" "project_eks" {
  name     = "project-eks"
  role_arn = aws_iam_role.eks-role.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = ["${aws_subnet.eks_vpc_public_subnet1.id}", "${aws_subnet.eks_vpc_public_subnet2.id}", "${aws_subnet.eks_vpc_private_subnet1.id}", "${aws_subnet.eks_vpc_private_subnet2.id}"]

}

depends_on = [
      aws_iam_role_policy_attachment.project-eks-policy1,
      aws_iam_role_policy_attachment.project-eks-policy2,
    ]
}

# Create EKS Cluster Nodes Group
# I AM Roles for EkS Nodes Group
resource "aws_iam_role" "eks-node-role" {
  name = "project-eks-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "project-eks-node-policy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "project-eks-node-policy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-role.name
}

resource "aws_iam_role_policy_attachment" "project-eks-node-policy3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-role.name
}

# Create EKS Node Group
resource "aws_eks_node_group" "project_eks_node" {
  cluster_name    = aws_eks_cluster.project_eks.name
  node_group_name = "project-eks-node"
  node_role_arn   = aws_iam_role.eks-node-role.arn
  subnet_ids      = ["${aws_subnet.eks_vpc_private_subnet1.id}", "${aws_subnet.eks_vpc_private_subnet2.id}"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }
  ami_type             = "AL2_x86_64"
  capacity_type        = "ON_DEMAND"
  disk_size            = 20
  instance_types       = ["t3.medium"]
  force_update_version = false
  version              = "1.27"
  depends_on = [
    aws_iam_role_policy_attachment.project-eks-node-policy1,
    aws_iam_role_policy_attachment.project-eks-node-policy2,
    aws_iam_role_policy_attachment.project-eks-node-policy3,
  ]
}