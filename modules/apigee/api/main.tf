# Enable Apigee API
resource "google_project_service" "apigee_api" {
  project               = var.project_id
  service               = "apigee.googleapis.com"
  disable_on_destroy    = false # Important: Keep this false
}