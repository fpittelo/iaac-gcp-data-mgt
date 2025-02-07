# Create Apigee Organization
resource "google_apigee_organization" "data-mgt-org" {
  display_name              = var.project_id
  project_id                = var.project_id
 

  # Optional: Description
  description = var.org_description

  # Optional: Properties (e.g., analytics region)
  properties {
    property {
      name  = var.analytics_region
      value = var.analytics_region # e.g., "europe-west1" (Switzerland) or "us-central1"
    }
  }

 depends_on = [google_project_service.apigee_api]
}