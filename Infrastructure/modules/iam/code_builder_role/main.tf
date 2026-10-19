data "aws_caller_indetity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "code_builder_role" {
  name = var.iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
            Service = "codebuild.amazonaws.com"
        }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "image_builder_policy" {
  name = "CodeBuildPolicy"
  role = aws_iam_role.code_builder_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        # ClouWatch Logs
        {
            Sid = "CloudWatchLogs"
            Effect = "Allow"
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
            Resource = "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:log-group:/aws/codebuild/*"
        },

        # ECR Access 
        {
            Sid = "ECRAccess"
            Effect = "Allow"
            Action = [
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatcjGetImage",
                "ecr:GetAuthorizationToken",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ]
            Resource = var.agent_ecr_repository_arn
            #Resource = aws_ecr_repository.agent_ecr.arn 
        },
        {
            Sid = "S3SourceAccess"
            Effect = "Allow"
            Action = [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ]
            Resource = "${aws_s3_bucket.agent_source.arn}/*"
        },
        {
            Sid = "S3BucketAccess"
            Effect = "Allow"
            Action = [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ]
            Resource = var.agent_source_s3_bucket_arn
        }
    ]
  })
}