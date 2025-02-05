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

# Create Input Folder
resource "google_storage_bucket_object" "input_folder" {
  bucket                  = var.bucket
  name                    = "${var.input_folder}/" # The trailing slash creates a folder
  # No content is needed for a folder
}

# Create Output Folder
resource "google_storage_bucket_object" "output_folder" {
  bucket                  = var.bucket
  name                    = "${var.output_folder}/" # The trailing slash creates a folder
  # No content is needed for a folder
}

# Create Temp Folder
resource "google_storage_bucket_object" "temp_folder" {
  bucket                  = var.bucket
  name                    = "${var.temp_folder}/" # The trailing slash creates a folder
  # No content is needed for a folder
}

# Create Error Folder

resource "google_storage_bucket_object" "error_folder" {
  bucket                  = var.bucket
  name                    = "${var.error_folder}/" # The trailing slash creates a folder
  # No content is needed for a folder
}

data "http" "input_file" {
  url = "https://github.com/fpittelo/iaac-gcp-data-mgt/blob/dev/README.md" # Replace with your GitHub URL
}

resource "google_storage_bucket_object" "input_file" {
  bucket = var.bucket
  name   = "${var.input_folder}/${var.input_file_name}"
  source = data.http.input_file.body # Use the content from GitHub
  depends_on = [google_storage_bucket_object.input_folder]
}

### BigQuery Deployment ###

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
  data_editor_group           = var.data_editor_group
  data_viewer_group           = var.data_viewer_group
  depends_on                  = [google_project_service.bigquery_api] # Ensure API is enabled first
}

output "dataset_self_link" {
  value       = module.bigquery_dataset.dataset_self_link  # Corrected line
  description = "The self link of the created dataset"
}

### Dataflow Deployment ###

resource "google_project_service" "dataflow_api" {
  project                     = var.project
  service                     = "dataflow.googleapis.com"
  disable_on_destroy          = true
}

module "dataflow" {
  source                      = "../modules/dataflow"
  project                     = var.project
  region                      = var.location
  temp_gcs_path               = var.temp_gcs_path
  temp_gcs_location           = var.temp_gcs_location
  max_workers                 = var.max_workers
  job_name                    = var.job_name
  input_subscription          = var.input_subscription
  output_topic                = var.output_topic
  depends_on                  = [google_project_service.dataflow_api] # Ensure API is enabled first
  
}

