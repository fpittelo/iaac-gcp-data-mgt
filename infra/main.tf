#### Create GCP Cloud Storage bucket ####

module "cloud_storage_bucket" {
  source                    = "../modules/cloud_storage_bucket"
  project                   = var.project
  zone                      = var.zone
  bucket                    = var.bucket
  location                  = var.location
  versioning_enabled        = var.versioning_enabled
  lifecycle_rule_age        = var.lifecycle_rule_age
  bucket_owner_email        = var.bucket_owner_email
  
}

resource "google_project_service" "bigquery_api" {
  project                     = var.project
  service                     = "bigquery.googleapis.com"
  disable_on_destroy          = true
  disable_dependent_services  = true
}
module "bigquery_dataset" {
  source                      = "../modules/bigquery"
  project                     = var.project
  location                    = var.location
  dataset_id                  = var.dataset_id
  dataset_description         = var.dataset_description
  default_table_expiration_ms = var.default_table_expiration_ms
  data_editor_group           = ""
  data_viewer_group           = ""
  depends_on                  = [google_project_service.bigquery_api] # Ensure API is enabled first
}

output "dataset_self_link" {
  value       = module.bigquery_dataset.dataset_self_link  # Corrected line
  description = "The self link of the created dataset"
}