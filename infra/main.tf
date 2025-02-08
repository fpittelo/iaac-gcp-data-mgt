### Activate GCP Project Services APIs ###
resource "google_project_service" "bigquery_api" {
  project                     = var.project_id
  service                     = "bigquery.googleapis.com"
  disable_on_destroy          = true
  disable_dependent_services  = true
}

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

resource "google_project_service" "bigquery_data_transfer_api" {
  service                     = "bigquerydatatransfer.googleapis.com"
  disable_on_destroy          = false # Garder l'API activée même si la ressource est détruite
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
resource "google_apigee_environment" "apigee_env" {
  org_id                  = var.apigee_org_id
  name                    = var.apigee_env_name  # Use the more specific variable name
  display_name            = var.apigee_env_display_name
  description             = var.apigee_env_description
  deployment_type         = var.apigee_env_deployment_type # Make sure this aligns with your Apigee setup

  node_config {
    min_node_count        = var.apigee_min_node_count
    max_node_count        = var.apigee_max_node_count
  }

  # KMS configuration (if needed)
  # kms_config {
  #   key_reference = var.kms_key_id  # If you're using CMEK
  # }
}

# Grant necessary permissions to the service account
resource "google_project_iam_member" "apigee_admin" {
  project = var.project_id
  role    = "roles/apigee.environmentAdmin" # Or a more granular role
  member  = "serviceAccount:${var.service_account_email}"
}

# Example: Output the Apigee environment name
output "apigee_environment_name" {
  value = google_apigee_environment.apigee_env.name
}