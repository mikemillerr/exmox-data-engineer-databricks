output "workspace_url" {
  description = "Existing Databricks workspace URL."
  value       = var.workspace_url
}

output "authenticated_user" {
  description = "Identity used by Terraform to access the workspace."
  value       = data.databricks_current_user.this.user_name
}
