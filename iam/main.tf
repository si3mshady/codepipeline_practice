resource "aws_iam_role" "code_pipeline_iam" {
  name = "code_pipeline_iam"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "codepipeline"
  }
}


data "aws_iam_policy_document" "codestar-permissions" {
  statement {
    actions = ["codestar-connections:*", "s3:*", "cloudwatch:*", "codebuild:*", "iam:*"]

    resources = ["*"]

    effect = "Allow"

  }

}

resource "aws_iam_policy" "codestar-permissions-policy" {
  name        = "codestar-permissions-policy"
  path        = "/"
  description = "codestar-permissions-policy"

  policy = data.aws_iam_policy_document.codestar-permissions.json
}



resource "aws_iam_policy_attachment" "codestar-policy-attach" {
  name       = "codestar-policy-attach"
  roles      = [aws_iam_role.code_pipeline_iam.name]
  policy_arn = aws_iam_policy.codestar-permissions-policy.arn
}


resource "aws_iam_policy_attachment" "codestar-policy-attach-2" {
  name       = "codestar-policy-attach-2"
  roles      =  [aws_iam_role.code_pipeline_iam.name]
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}