# # Create a local file to store data
# resource "local_file" "ebs_volume_id" {
#     content  = aws_ebs_volume.project_eks_ebs_volume.id
#     filename = "ebsvolume.txt"

# }