terraform {

  
  backend "s3" {
    bucket = "sample-eks-blueprint"
    key    = "sample/eksblueprint/eks-blueprint.tf"
    region = "eu-west-1"

    profile = "SB102"
  }
}
provider "aws" {
  region = "eu-west-1"
  profile = "SB102"
}