variable "iam_role_name" {
  type        = string
  description = "agent execution iam role name"
}

variable "ecr_repository_arn"{
  type = string
  description = "agent code ECR repository ARN"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}