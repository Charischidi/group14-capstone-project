# AWS Backend
terraform {
  backend "s3" {
    bucket  = "capstone-project-bckt"
    key     = "eks-cluster/capstprjt.tfstate"
    region  = "us-east-1"
    encrypt = true

  }
}