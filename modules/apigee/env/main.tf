# Create Apigee Environment within the organization
resource "google_apigee_environment" "data-mgt-env" {
  name                  = var.apigee_env
  org_id                = module.google_apigee_organization.data-mgt-org.id
  display_name          = var.apigee_env_description

  # Optional: Description
  description           = var.apigee_env_description

  # Optional: Deployment type (usually "STANDARD")
  deployment_type       = var.apigee_env_deployment_type

  # Optional: Kms Encryption Config
  # kms_encryption_config {
  #   kms_key_name = var.kms_key_name
  # }

  # Optional: Node Config
  node_config {
    min_node_count      = var.apigee_min_node_count
    max_node_count      = var.apigee_max_node_count
  }
}