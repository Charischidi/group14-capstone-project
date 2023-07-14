# Create OpenId connect provider
data "tls_certificate" "project-eks-tls" {
  url = aws_eks_cluster.project_eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.project-eks-tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.project_eks.identity[0].oidc[0].issuer
}


# # Create IAM Policy, Roles with OIDC and Install EBS-CSI driver for AMAZON EBS 
# # https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
# data "aws_iam_policy" "project-eks-ebs_csi_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
# }

# module "irsa-ebs-csi" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "4.7.0"

#   create_role                   = true
#   role_name                     = "AmazonEKSTFEBSCSIRole-Project-EKS"
#   provider_url                  = aws_iam_openid_connect_provider.oidc_provider.url
#   role_policy_arns              = [data.aws_iam_policy.project-eks-ebs_csi_policy.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
# }

# resource "aws_eks_addon" "project-eks-ebs-csi" {
#   cluster_name             = aws_eks_cluster.project_eks.name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.19.0-eksbuild.1"
#   resolve_conflicts = "OVERWRITE"
#   service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
#   tags = {
#     "eks_addon" = "ebs-csi"
#     "terraform" = "true"
#   }
# }

# # Create AWS EBS Volume
# resource "aws_ebs_volume" "project_eks_ebs_volume" {
#   availability_zone = "us-east-1a"
#   size              = 10

#   tags = {
#     Name = "Project-eks-ebs-volume"
#   }

#   depends_on = [ aws_eks_addon.project-eks-ebs-csi ]
# }