resource "databricks_mws_credentials" "this" {
  provider         = databricks.account
  account_id       = var.databricks_account_id
  credentials_name = "${var.name_prefix}-credentials"
  role_arn         = aws_iam_role.cross_account.arn

  depends_on = [aws_iam_role_policy.cross_account]
}

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.account
  account_id                 = var.databricks_account_id
  storage_configuration_name = "${var.name_prefix}-storage"
  bucket_name                = aws_s3_bucket.root.bucket

  depends_on = [aws_s3_bucket_policy.root]
}

resource "databricks_mws_networks" "this" {
  provider           = databricks.account
  account_id         = var.databricks_account_id
  network_name       = "${var.name_prefix}-network"
  vpc_id             = aws_vpc.this.id
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.workspace.id]

  depends_on = [
    aws_route.private_default,
    aws_vpc_endpoint.s3,
    aws_vpc_security_group_egress_rule.all_ipv4,
    aws_vpc_security_group_ingress_rule.self_tcp,
    aws_vpc_security_group_ingress_rule.self_udp,
  ]
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.account
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  aws_region     = var.aws_region

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  custom_tags = var.tags

  timeouts {
    create = "30m"
    read   = "10m"
    update = "20m"
  }
}
