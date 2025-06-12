terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }

  backend "s3" {
    bucket = "the-wedding-game"
    key = "terraform/state/terraform.tfstate"
    region = "eu-west-1"
  }

  required_version = "~> 1.12.1"
}

provider "aws" {
  region = "eu-west-1"
}

