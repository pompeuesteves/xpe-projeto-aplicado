provider "aws" {
  region = var.aws_region
}


# Centralizar o arquivo de controle de estado do terraform
terraform {
  backend "s3" {
    bucket = "tf-state-igti-713051429766"
    key    = "state/xpe/projetoaplicado/terraform.tfstate"
    region = "us-east-2"
  }
}