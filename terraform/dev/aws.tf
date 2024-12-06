terraform {
  required_version = ">= 1.1.5"
  required_providers {
    aws = {
      version = "~> 4.51.0"
    }
    archive = {
      version = "2.2.0"
    }

  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "default-region"
  region = "ap-south-1"
}
