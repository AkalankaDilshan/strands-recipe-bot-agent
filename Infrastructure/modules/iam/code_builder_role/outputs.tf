output "agent_execution_role_arn" {
    value = aws_iam_role.agent_execution.arn
    description = "Bedrock Agentcore execution role arn"
}