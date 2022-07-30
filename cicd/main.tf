#code commit 
#code artifact (like nessus)


#aws parameter store 
#code build 
#code deploy 
#code pipeline


# --
# sonar cloud 
# linter  checkstyle



// sonar cloud  - ssm parameter

# data "template_file" "buildspec" {
#   template = "${file("buildspec.yml")}"
#   vars = {
#     env          = var.env
#   }
# }


resource "aws_ssm_parameter" "params" {

  for_each = {
    username = var.username
    # password = var.password
    # connectionArn = var.connectionArn
    appID = var.appID
  }

  name  = each.value
  type  = "String"
  value = each.value

}





resource "aws_iam_role" "cb_service_role" {
  name = "cb_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service =  "codebuild.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "codebuild"
  }
}



resource "aws_iam_role" "cp_service_role" {
  name = "cp_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service =  "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "codebuild"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "cb_service_policy"
  path        = "/"
  description = "cb_service_policy"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}



resource "aws_iam_policy" "cp_policy" {
  name        = "cp_service_policy"
  path        = "/"
  description = "cp_service_policy"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_policy_attachment" "cp-policy-attach" {
  name       = "policy-attach"
  roles      = [aws_iam_role.cp_service_role.name]
  policy_arn = aws_iam_policy.cp_policy.arn
}




resource "aws_iam_policy_attachment" "policy-attach" {
  name       = "policy-attach"
  roles      = [aws_iam_role.cb_service_role.name]
  policy_arn = aws_iam_policy.policy.arn
}



resource "aws_codebuild_project" "job1" {
  name           = "job1"
  description    = "first job in pipeline"
  service_role  = aws_iam_role.cb_service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "terraform:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

     registry_credential {
     credential = "arn:aws:secretsmanager:us-west-1:596780849713:secret:cicd-user-pass-github-MCgpto"
     credential_provider = "SECRETS_MANAGER"
   }

  }

  source {
    type            = "CODEPIPELINE"
    buildspec           = file("${path.module}/buildspec.yml")
  }
}



resource "aws_codebuild_project" "job2" {
  name           = "job2"
  description    = "second job in pipeline"
  service_role  = aws_iam_role.cb_service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "terraform:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

   registry_credential {
     credential = "arn:aws:secretsmanager:us-west-1:596780849713:secret:cicd-user-pass-github-MCgpto"
     credential_provider = "SECRETS_MANAGER"
   }

  }

  source {
    type            = "CODEPIPELINE"
    buildspec           = file("${path.module}/deploy_buildspec.yml")
  }
}



resource "aws_codepipeline" "codepipeline" {
  name     = "cicd"

  role_arn =  aws_iam_role.cp_service_role.arn

  artifact_store {
    location = var.s3_artifacts.bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:us-west-1:596780849713:connection/a9a4a0ef-6538-443a-bfda-db3215b1b0b9"
        FullRepositoryId = "si3mshady/youtube-downloader"
        BranchName       = "master"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
        name ="Plan"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "saturday-cicd"
            }
        }
    }



  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["tf-code"]
      version         = "1"

      configuration = {
        ProjectName = "cicd-saturday"
      }
    }
  }
}
