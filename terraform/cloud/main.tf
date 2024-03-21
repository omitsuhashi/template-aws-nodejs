terraform {
  required_version = ">= 1.7.4"
  backend "s3" {
    bucket = "deploy-management-bucket"
    key    = "{service_name}/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region     = "ap-northeast-1"
}

module "main" {
  source = "../shares"
}
