### Grant the necessary permissions to the service account ###

resource "google_project_iam_member" "multiple_roles" {
  project = var.project_id
  member  = "serviceAccount:github-wif-sa@iaac-gcp-data-mgt.iam.gserviceaccount.com"
  role = [
    "roles/serviceusage.serviceUsageAdmin",
    "roles/bigquery.dataOwner",
    "roles/storage.objectAdmin",
  ]
}

### Manages the service identity for Pub/Sub service ###
resource "google_project_service_identity" "df_pubsub_identity" {
  provider = google-beta
  service  = "pubsub.googleapis.com"
}

### Managing the service identity of a service ###
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
    "dataflow_api.googleapis.com",
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
}

### BigQuery tables creation ###
#resource "google_bigquery_dataset" "main" {
#dataset_id                   = "iaac_gcp_data_mgt_dataset"
#}

resource "google_bigquery_table" "stream_data" {
  dataset_id                  = module.bigquery_dataset.dataset_id
  table_id                    = "data-mgt-table-stream"
  schema                      = <<EOF
[
  {
    "name": "event_time",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "Timestamp of the event"
  },
  {
    "name": "data",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Event data as a JSON string"
  }
]
EOF
}

resource "google_bigquery_table" "batch_data" {
  dataset_id                  = module.bigquery_dataset.dataset_id
  table_id                    = "data-mgt-table-batch"
  schema                      = <<EOF
[
  {
    "name": "ingestion_time",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "Timestamp of the ingestion"
  },
  {
    "name": "data",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Batch data as a JSON string"
  }
]
EOF
}

### BigQuery outputs ###
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