# output "vpc_id" {
#   value       = aws_vpc.eks_vpc.id
#   description = "VPC id"
#   sensitive   = false
# }

# output "endpoint" {
#   value = aws_eks_cluster.project_eks.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.project_eks.certificate_authority.0.data
# }

# output "ebs_volume_id" {
#  value = aws_ebs_volume.project_eks_ebs_volume.id
# }
