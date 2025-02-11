### Grant the necessary permissions to the service account ###

resource "google_project_iam_member" "multiple_roles" {
  for_each = toset(var.roles)
  project = var.project_id
  role    = each.key
  member  = var.member
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
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "google_project_iam_member" "service_account_bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "bq_dataset_delete" {
  project = var.project_id
  role    = "roles/bigquery.dataOwner"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "service_account_bigquery_metadata_viewer" {
  project = var.project_id
  role    = "roles/bigquery.metadataViewer"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "bq_dataset_view" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${var.service_account_email}"
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

resource "null_resource" "create_rail_traffic_csv" {
  provisioner "local-exec" {
    command = "curl -s -L 'https://data.sbb.ch/api/v2/catalog/datasets/rail-traffic-information/exports/csv?use_labels=true' -o ${path.module}/rail_traffic.csv"
  }
}

# Download and stage the data in Cloud Storage
resource "google_storage_bucket_object" "rail_traffic_data" {
  bucket = var.bucket
  name   = "inputs/rail_traffic.csv" # Path within your bucket
  depends_on = [ null_resource.create_rail_traffic_csv ]
  # Use a local file as a trigger for updates.
  # This makes the resource update when the file changes.
  source = "${path.module}/rail_traffic.csv"  # Create a dummy rail_traffic.csv in your module

  # Provisioner to download the data to the dummy file
  provisioner "local-exec" {
    command = "curl -L 'https://data.sbb.ch/api/v2/catalog/datasets/rail-traffic-information/exports/csv?use_labels=true' -o ${path.module}/rail_traffic.csv"
  }
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

  depends_on = [ 
    google_project_iam_member.service_account_bigquery_admin,
    google_project_iam_member.bq_dataset_delete,
   ]
}

resource "google_bigquery_table" "stream_data" {
  dataset_id                  = module.bigquery_dataset.dataset_id
  deletion_protection         = false
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

  # Important for deletion control:
 lifecycle {
   prevent_destroy = false # Allow deletion by default
 }

}

resource "google_bigquery_table" "batch_data" {
  dataset_id                  = module.bigquery_dataset.dataset_id
  deletion_protection         = false
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

  # Important for deletion control:
 lifecycle {
   prevent_destroy = false # Allow deletion by default
 }

}

### BigQuery outputs ###
output "dataset_self_link" {
  value       = module.bigquery_dataset.dataset_self_link  # Corrected line
  description = "The self link of the created dataset"
}