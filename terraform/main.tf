data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones    = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidr    = cidrsubnet(var.vpc_cidr, 4, 0)
  private_subnet_cidrs  = [for index in range(2) : cidrsubnet(var.vpc_cidr, 4, index + 1)]
  root_bucket_name      = "${var.name_prefix}-root-${data.aws_caller_identity.current.account_id}"
  cross_account_role_id = "${var.name_prefix}-crossaccount"

  aws_tags = merge(
    {
      ManagedBy = "Terraform"
      Project   = var.name_prefix
    },
    var.tags,
  )
}
