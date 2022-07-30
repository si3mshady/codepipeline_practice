
provider "aws" {
  region     = "us-west-1"
 
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }
}

