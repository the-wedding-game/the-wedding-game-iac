terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }

  backend "s3" {}

  required_version = "~> 1.12.1"
}

provider "aws" {
  region = "eu-west-1"
}

