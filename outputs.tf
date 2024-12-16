# Outputs
output "grafana_workspace_url" {
  value = aws_grafana_workspace.demo.endpoint
}

output "grafana_workspace_service_token" {
  value     = aws_grafana_workspace_service_account_token.demo_admin.key
  sensitive = true
}