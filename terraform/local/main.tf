terraform {
  required_version = ">= 1.7.4"
  backend "local" {}
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = "localstack"
  secret_key = "localstack"

  endpoints {
    s3         = "http://s3.localhost.localstack.cloud:4566"
    lambda     = "http://localhost:4566"
    apigateway = "http://localhost:4566"
    sts        = "http://localhost:4566"
    iam        = "http://localhost:4566"
  }
}

module "main" {
  source = "../shares"

  database_url = "postgresql://postgres:postgres@postgres:5432/postgres"
}
