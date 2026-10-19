provider "aws" {
  region = "us-west-1"
}

module "iam_agent_execution" {
  source = "./modules/iam/agent_execution_Role"
  iam_role_name = "recipe-bot-agent-execution-role"
  tags = {
    Environment = var.environment
    Name        = "recipe-bot-agent-execution-role"
    CreatedBy   = "AkalankaDilshan"
    ManagedBy   = "Terraform"
  }
}

module "iam_ecr_builder_role" {
  source = "./modules/iam/code_builder_role"
  iam_role_name = "recipe-bot-agent-code-builder-role"
  agent_ecr_repository_arn = "dfdf" #need to change
  agent_source_s3_bucket_arn = "dfdf" # need to change
}

