terraform {
  backend "s3" {
    bucket = "deploy-tfstate"
    key    = "terraform.tfstate/dev-ap-south-1"
    region = "ap-south-1"
  }
}
