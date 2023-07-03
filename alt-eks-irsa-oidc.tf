# # IAM Role with OIdC For EKS EBS CSI Installation
# data "tls_certificate" "project-eks-tls" {
#   url = aws_eks_cluster.project_eks.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "oidc_provider" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.project-eks-tls.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.project_eks.identity[0].oidc[0].issuer
# }

# data "aws_iam_policy_document" "oidc_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "eks-esb-csi-role" {
#   assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
#   name               = "eks-esb-csi-role"
# }

# resource "aws_iam_role_policy_attachment" "ebs-csi-policy-attachement" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.eks-esb-csi-role.name
# }

# resource "aws_eks_addon" "project-eks-ebs-csi" {
#   cluster_name             = aws_eks_cluster.project_eks.id
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.19.0-eksbuild.1"
#   resolve_conflicts = "OVERWRITE"
#   service_account_role_arn =  aws_iam_role.eks-esb-csi-role.arn
#   tags = {
#     "eks_addon" = "ebs-csi"
#     "terraform" = "true"
#   }
# }