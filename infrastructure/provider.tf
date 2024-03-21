provider "aws" {
  region = "ca-central-1"
}

module "sg" {
  source = "./sg"
}

module "ec2" {
  source = "./ec2"
}
