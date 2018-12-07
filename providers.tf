terraform {
  backend "s3" {
    bucket = "terraform.grimoire"
    key    = "network.tfstate"
    region = "ca-central-1"
  }
}

provider "aws" {
  version = "~> 1.11"

  region = "ca-central-1"
}
