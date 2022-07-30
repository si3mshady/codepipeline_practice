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
    project = var.project_name
    organization = var.organization
    url = var.sonar_cloud_url
    key = var.key
  }

  name  = each.value
  type  = "String"
  value = each.value

}


# resource "aws_iam_role" "cb_service_role" {
#   name = "cb_service_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codebuild.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# }
# EOF
# }




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




resource "aws_iam_policy_attachment" "policy-attach" {
  name       = "policy-attach"
  roles      = [aws_iam_role.cb_service_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_codebuild_project" "code_analysis" {
  name           = "test-project-cache"
  description    = "test_codebuild_project_cache"
  service_role  = aws_iam_role.cb_service_role.arn
  build_timeout  = "5"
  queued_timeout = "5"


  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }



  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "SOME_KEY1"
      value = "SOME_VALUE1"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/bennymeier/youtube-downloader.git"
    git_clone_depth = 1
    buildspec           = file("${path.module}/buildspec.yml")
  }

  tags = {
    Environment = "Test"
  }
}




# resource "aws_codebuild_project" "example" {
#   name          = "test-project"
#   description   = "test_codebuild_project"
#   build_timeout = "5"
#   service_role  = aws_iam_role.example.arn

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   cache {
#     type     = "S3"
#     location = aws_s3_bucket.example.bucket
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:1.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "SOME_KEY1"
#       value = "SOME_VALUE1"
#     }

#     environment_variable {
#       name  = "SOME_KEY2"
#       value = "SOME_VALUE2"
#       type  = "PARAMETER_STORE"
#     }
#   }

#   logs_config {
#     cloudwatch_logs {
#       group_name  = "log-group"
#       stream_name = "log-stream"
#     }

#     s3_logs {
#       status   = "ENABLED"
#       location = "${aws_s3_bucket.example.id}/build-log"
#     }
#   }

#   source {
#     type            = "GITHUB"
#     location        = "https://github.com/mitchellh/packer.git"
#     git_clone_depth = 1

#     git_submodules_config {
#       fetch_submodules = true
#     }
#   }
