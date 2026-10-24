data "databricks_aws_assume_role_policy" "cross_account" {
  provider    = databricks.account
  external_id = var.databricks_account_id
}

resource "aws_iam_role" "cross_account" {
  name               = local.cross_account_role_id
  assume_role_policy = data.databricks_aws_assume_role_policy.cross_account.json
}

data "databricks_aws_crossaccount_policy" "customer_vpc" {
  provider    = databricks.account
  policy_type = "customer"
}

resource "aws_iam_role_policy" "cross_account" {
  name   = "${var.name_prefix}-workspace-provisioning"
  role   = aws_iam_role.cross_account.id
  policy = data.databricks_aws_crossaccount_policy.customer_vpc.json
}
