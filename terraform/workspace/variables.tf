variable "workspace_url" {
  description = "URL of the existing Databricks workspace."
  type        = string

  validation {
    condition     = can(regex("^https://[^/]+\\.cloud\\.databricks\\.com/?$", var.workspace_url))
    error_message = "workspace_url must be an HTTPS Databricks workspace URL without a path."
  }
}
