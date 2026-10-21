variable "iam_role_name" {
  type        = string
  description = "agent execution iam role name"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}