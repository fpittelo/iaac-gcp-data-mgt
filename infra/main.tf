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
    "bigquerydatatransfer.googleapis.com",
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

resource "google_project_iam_member" "bigquery_data_transfer_service_agent" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:service-571690378641@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
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

resource "null_resource" "create_swissgrid_csv" {
  provisioner "local-exec" {
    command = <<EOT
      curl -s -L https://www.uvek-gis.admin.ch/BFE/ogd/103/ogd103_stromverbrauch_swissgrid_lv_und_endv.csv -o ${path.module}/swissgrid.csv
      sleep 60
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Download and stage the data in Cloud Storage
resource "google_storage_bucket_object" "swissgrid_data" {
  bucket = var.bucket
  name   = "inputs/swissgrid.csv" # Path within your bucket
  depends_on = [ null_resource.create_swissgrid_csv ]
  # Use a local file as a trigger for updates.
  # This makes the resource update when the file changes.
  source = "${path.module}/swissgrid.csv"  # Create swissgrid.csv 
  lifecycle {
    ignore_changes = [ detect_md5hash ]
  }
  ## Provisioner to download the data to the dummy file
  provisioner "local-exec" {
    command = <<EOT
      curl -L https://www.uvek-gis.admin.ch/BFE/ogd/103/ogd103_stromverbrauch_swissgrid_lv_und_endv.csv -o ${path.module}/swissgrid.csv
      sleep 60
    EOT
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

resource "google_bigquery_table" "swissgrid_data" {
  dataset_id                  = module.bigquery_dataset.dataset_id
  deletion_protection         = false
  table_id                    = "swissgrid_data"
  schema                      = <<-EOF
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
    },
    {
      "name": "Datum",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "Date of the data"
    },
    {
      "name": "Landesverbrauch_GWh",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "National consumption in GWh"
    },
    {
      "name": "Endverbrauch_GWh",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "Final consumption in GWh"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "batch_data" {
  dataset_id                  = module.bigquery_dataset.dataset_id
  deletion_protection         = false
  table_id                    = "data-mgt-table-batch"
  schema                      = <<-EOF
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

  lifecycle {
    prevent_destroy = false
  }
}

### Bigquery Transfer Configuration ###

resource "google_bigquery_data_transfer_config" "swissgrid_transfer" {
  data_source_id                    = "google_cloud_storage"
  destination_dataset_id            = module.bigquery_dataset.dataset_id
  location                          = var.location
  display_name                      = "Swissgrid Data Transfer"
  schedule                          = "every 24 hours"

  params = {
    destination_table_name_template = "swissgrid_data"
    data_path_template              = "gs://${var.bucket}/inputs/swissgrid.csv"
#   source_uris                     = "gs://${var.bucket}/inputs/swissgrid.csv"
    format                          = "CSV"
    skip_leading_rows               = 1
    write_disposition               = "WRITE_TRUNCATE"
  }

  depends_on = [
    google_storage_bucket_object.swissgrid_data
  ]
}

output "dataset_self_link" {
  value       = module.bigquery_dataset.dataset_self_link  # Corrected line
  description = "The self link of the created dataset"
}