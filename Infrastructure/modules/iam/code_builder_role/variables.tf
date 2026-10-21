variable "iam_role_name" {
  type        = string
  description = "code builder iam role name"
}

variable "agent_source_s3_bucket_arn" {
  type        = string
  description = "S3 bucket arn"
}

variable "agent_ecr_repository_arn" {
  type        = string
  description = "Ecr Repository Arn"
}
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}