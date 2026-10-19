data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "agent_execution" {
  name = "${var.agent-name}-execution-role"
  assume_role_policy = jsondecode({
    Version = "2012-10-17"
    Statement = [{
        Sid = "AssumeRolePolicy"
        Effect = "Allow"
        Principal = {
            Service = "bedrock-agentcore.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
            StringEquals = {
                "aws:SourceAccount" = data.aws_caller_identity.current
                }
            ArnLike = {
                "aws:SourceArn" = "arn:aws:bedrock-agentcore:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:*"
            }
        }
    }]
  })

  tags = var.tags
}

#AWS managed policy for AgentCore
resource "aws_iam_role_policy_attachment" "agent_execution_managed" {
  role = aws_iam_role.agent_execution.name
  policy_arn = "arn:aws:iam::aws:policy/BedrockAgentCoreFullAccess"
}


resource "aws_iam_role_policy" "agent_ecr_execution" {
  name = "AgentCoreExecutionPolicy"
  role = aws_iam_role.agent_execution.id

  policy = jsondecode ({
    Version = "2012-10-17"
    Statement = [
         # ECR Access policy
        {
            Sid = "ECRImageAccess"
            Effect = "Allow"
            Action = [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchCheckLayerAvailability"
            ]
            Resource = aws_ecr_repository.agent_ecr.arn 
        },
        {
            Sid      = "ECRTokenAccess"
            Effect   = "Allow"
            Action   = ["ecr:GetAuthorizationToken"]
            Resource = "*"
        },

         # CloudWatch Logs Policy
        {
            Sid    = "CloudWatchLogs"
            Effect = "Allow"
            Action = [
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
            Resource = "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:log-group:/aws/bedrock-agentcore/runtimes/*"
      },
      # X-ray Tracing Policy
      {
        Sid = "XRayTracing"
        Effect = "Allow"
        Action = [
            "xray:PutTraceSegments",
            "xray:PutTelemetryRecords",
            "xray:GetSamplingRules",
            "xray:GetSamplingTargets"
        ]
        Resource = "*"
      },

      # ClaudWatch Metrics
      {
        Sid = "CloudWatchMetrics"
        Effect = "Allow"
        Action = [
            "cloudwatch:PutMetricData"
        ]
        Resource = "*"
        Condition = {
            StringEquals = {
                "cloudwatch:namespace" = "bedrock-agentcore"
            }
        }
      },
      # Bedrock Model Invocation
      {
        Sid = "BedrockModelInvocation"
        Effect = "Allow"
        Action = [
            "bedrock:InvokeModel",
            "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "*"
      },
      # Workload Access Token
      {
        Sid = "GetAgentAccessToken"
        Effect = "Allow"
        Action = [
            "bedrock-agentcore:GetWorkloadAccessToken",
            "bedrock-agentcore:GetWorkloadAccessTokenForJWT",
            "bedrock-agentcore:GetWorkloadAccessTokenForUserId"
        ]
        Resource = [
            "arn:aws:bedrock-agentcore:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:workload-identity-directory/default",
            "arn:aws:bedrock-agentcore:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:workload-identity-directory/default/workload-identity/*"
        ]
      }
    ]
  })
}