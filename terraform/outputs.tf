output "workspace_id" {
  description = "Numeric Databricks workspace ID."
  value       = databricks_mws_workspaces.this.workspace_id
}

output "workspace_url" {
  description = "URL used to open the workspace and configure workspace-level providers."
  value       = databricks_mws_workspaces.this.workspace_url
}

output "workspace_status" {
  description = "Databricks workspace provisioning status."
  value       = databricks_mws_workspaces.this.workspace_status
}

output "root_bucket_name" {
  description = "S3 bucket used for Databricks workspace root storage."
  value       = aws_s3_bucket.root.bucket
}

output "cross_account_role_arn" {
  description = "AWS IAM role assumed by Databricks to manage workspace compute."
  value       = aws_iam_role.cross_account.arn
}
