variable "databricks_account_id" {
  description = "Databricks account ID from the account console (not the AWS account ID)."
  type        = string

  validation {
    condition     = length(trimspace(var.databricks_account_id)) > 0
    error_message = "databricks_account_id must not be empty."
  }
}

variable "workspace_name" {
  description = "Human-readable Databricks workspace name."
  type        = string
  default     = "exmox-data-engineer"

  validation {
    condition     = length(trimspace(var.workspace_name)) > 0
    error_message = "workspace_name must not be empty."
  }
}

variable "name_prefix" {
  description = "Lowercase prefix for AWS and Databricks account resources; change it to deploy another isolated workspace."
  type        = string
  default     = "exmox-data-engineer"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,26}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must be 2-28 characters of lowercase letters, numbers, and hyphens, and start and end with a letter or number."
  }
}

variable "aws_region" {
  description = "AWS region for the workspace and its resources."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR. The default produces /24 public and private subnets."
  type        = string
  default     = "10.20.0.0/20"

  validation {
    condition     = can(cidrsubnet(var.vpc_cidr, 4, 2))
    error_message = "vpc_cidr must be a valid CIDR with room for at least three subnets."
  }
}

variable "root_bucket_force_destroy" {
  description = "Allow Terraform to delete a non-empty workspace root bucket. Keep false to prevent accidental data loss."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for AWS resources and the Databricks workspace."
  type        = map(string)
  default     = {}
}
