# Create a Grafana workspace
resource "aws_grafana_workspace" "demo" {
  name                     = "grafana-demo"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana.arn

  data_sources = ["CLOUDWATCH"]
}

# Generate AWS Grafana workspace service account with Admin role to configure Grafana and create dashboards
resource "aws_grafana_workspace_service_account" "demo_admin" {
  name         = "demo-admin"
  grafana_role = "ADMIN"
  workspace_id = aws_grafana_workspace.demo.id
}

# Generate a token with sufficient TTL session
resource "aws_grafana_workspace_service_account_token" "demo_admin" {
  name               = "demo-admin-key"
  service_account_id = aws_grafana_workspace_service_account.demo_admin.service_account_id
  seconds_to_live    = 3600
  workspace_id       = aws_grafana_workspace.demo.id
}

# Configure Grafana workspace SAML attributes mapping
resource "aws_grafana_workspace_saml_configuration" "demo" {

  admin_role_values       = ["Grafana_Admins"]
  editor_role_values      = ["Grafana_Editors"]
  groups_assertion        = "groups"
  # Replace this dummy IdP metadata url for SAML to work
  idp_metadata_url        = "https://replace.link.with.your.idp.metadata.url/"
  role_assertion          = "groups"
  workspace_id            = aws_grafana_workspace.demo.id
}
