#### Create GCP Cloud Storage bucket ####

module "cloud_storage_bucket" {
  source                    = "../modules/cloud_storage_bucket"
  project                   = var.project_id
  zone                      = var.zone
  bucket                    = var.bucket
  location                  = var.location
  versioning_enabled        = var.versioning_enabled
  lifecycle_rule_age        = var.lifecycle_rule_age
  bucket_owner_email        = var.bucket_owner_email  
}

# Fetch input file from GitHub (Corrected URL)
data "http" "bucket" {
  url                         = "https://raw.githubusercontent.com/GoogleCloudPlatform/DataflowTemplates/master/apache_beam_wordcount/README.md"
}

resource "google_storage_bucket_object" "input_file" {
  bucket                    = module.cloud_storage_bucket.bucket_name
  name                      = "inputs/readme.md"
  content                   = data.http.bucket.response_body # Correction: Utilisation de response_body
}

### BigQuery Deployment ###
resource "google_project_service" "bigquery_api" {
  project                     = var.project_id
  service                     = "bigquery.googleapis.com"
  disable_on_destroy          = true
  disable_dependent_services  = true
}

module "bigquery_dataset" {
  source                      = "../modules/bigquery"
  project                     = var.project_id
  location                    = var.location
  dataset_id                  = var.dataset_id
  dataset_description         = var.dataset_description
  default_table_expiration_ms = var.default_table_expiration_ms
  dataset_owner_email         = var.dataset_owner_email
  data_editor_group           = var.data_editor_group
  data_viewer_group           = var.data_viewer_group
  depends_on                  = [google_project_service.bigquery_api] # Ensure API is enabled first
}

output "dataset_self_link" {
  value       = module.bigquery_dataset.dataset_self_link  # Corrected line
  description = "The self link of the created dataset"
}

### Activate GCP Project Services APIs ###
resource "google_project_service" "dataflow_api" {
  project                     = var.project_id
  service                     = "dataflow.googleapis.com"
  disable_on_destroy          = true
}

resource "google_project_service" "cloudfunctions_api" {
  project                     = var.project_id # Replace with your actual project ID
  service                     = "cloudfunctions.googleapis.com"
  disable_on_destroy          = true
}

resource "google_project_service" "pubsub_api" {
  project                     = var.project_id
  service                     = "pubsub.googleapis.com"
  disable_on_destroy          = true
  disable_dependent_services  = true
}

resource "google_project_service" "apigee_api" {
  project                     = var.project_id
  service                     = "apigee.googleapis.com"
  disable_on_destroy          = false # Recommended: Keep this as false
}

resource "google_project_service" "cloudkms_api" {
  project                     = var.project_id
  service                     = "cloudkms.googleapis.com"
  disable_on_destroy          = false # Recommended: Keep this as false
}

resource "google_project_service" "servicenetworking_api" {
  project = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# Dataflow Job (Corrected)
resource "google_dataflow_job" "wordcount_job" {
  project                     = var.project_id
  region                      = var.region
  name                        = "wordcount-job"
  template_gcs_path           = "gs://dataflow-templates-us-central1/latest/Word_Count"  # Or a custom template if needed
  temp_gcs_location           = "gs://${module.cloud_storage_bucket.bucket_name}/${var.temp_folder}" # Correct path!

  parameters = {
    inputFile                 = "gs://${module.cloud_storage_bucket.bucket_name}/${var.input_folder}/${var.input_file_name}" # Correct path!
    output                    = "gs://${module.cloud_storage_bucket.bucket_name}/${var.output_folder}/wordcount.txt"  # Correct path!
  }

  depends_on = [
    google_project_service.dataflow_api,
    module.cloud_storage_bucket,  # Depend on the bucket module
    google_storage_bucket_object.input_file, # Depend on the input file
    module.bigquery_dataset # Depend on bigquery dataset if needed
  ]
}

#### Deploy Pub/Sub Topic and Subscription ####


####    Deploy Apigee Organization   ####
module "google_apigee_organization" {
  source                  = "../modules/apigee/org"
  project_id              = var.project_id
  org_description         = var.project_id
  region                  = var.region
  analytics_region        = var.region

}

####    Deploy Apigee Organization   ####
module "google_apigee_environment" {
  source                      = "../modules/apigee/env"
  apigee_env                  = var.apigee_env
  apigee_env_display_name     = var.apigee_env_display_name
  apigee_env_description      = var.apigee_env_description
  apigee_env_deployment_type  = var.apigee_env_deployment_type
  apigee_min_node_count       = var.apigee_min_node_count
  apigee_max_node_count       = var.apigee_max_node_count
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  project  = var.project_id
  service  = each.value
}