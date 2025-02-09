### Activate GCP Project Services APIs ###
resource "google_project_service_identity" "df_pubsub_identity" {
  provider = google-beta
  service  = "pubsub.googleapis.com"
}

resource "google_project_service_identity" "df_dataflow_identity" {
  provider = google-beta
  service  = "dataflow.googleapis.com"
}

resource "google_project_service" "api_activations" {
  for_each = toset([
    "bigquery.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "compute.googleapis.com",
    "dataflow.googleapis.com",
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com",
  # "vertexai.googleapis.com",
  # "cloudsql.googleapis.com",
  ])
  service            = each.key
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
# depends_on                  = [google_project_service.bigquery_api] # Ensure API is enabled first
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
  # google_project_service.dataflow_api,
    module.cloud_storage_bucket,  # Depend on the bucket module
    google_storage_bucket_object.input_file, # Depend on the input file
    module.bigquery_dataset # Depend on bigquery dataset if needed
  ]
}

#### Deploy Pub/Sub Topic and Subscription ####


####    Deploy Apigee Organization   ####