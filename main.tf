module "cicd" {
  source = "./cicd"
   username =  var.username
   password = var.password
   appID = var.appID
   connectionArn = var.connectionArn
   s3_bucket = module.s3.s3_bucket
   s3_artifacts = module.s3.s3_artifacts
   

}


module "s3" {
    source = "./s3"
    bucket_name = var.bucket_name
    bucket_artifacts = var.bucket_artifacts
    
}


# module "iam" {
#     source = "./iam"

# }

provider "aws" {
  region     = "us-west-1"
 
}


# output "cp-iam-arn" {
#   value = module.iam.codepipeline-iam-arn
# }

terraform {

    backend "s3" {
      bucket = "cicd-si3mshady"
      encrypt = true
      key = "terraform.tfstate"
      region = "us-west-1"
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }
}

