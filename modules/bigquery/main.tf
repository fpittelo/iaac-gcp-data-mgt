### Module for BigQuery Dataset ###

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset_id
  location                    = var.location
  default_table_expiration_ms = var.default_table_expiration_ms # Optional: Table expiration
  delete_contents_on_destroy  = true

  # Optional: Description
  description                 = var.dataset_description

  # Optional: Default encryption configuration (Customer-managed encryption keys)
  # default_encryption_configuration {
  #   kms_key_name = var.kms_key_name
  # }

  # Optional: Access grants (example - for a group)
  access {
    role          = "roles/bigquery.dataViewer"
    group_by_email = var.data_viewer_group # Example
  }

    access {
    role          = "roles/bigquery.dataEditor"
    group_by_email = var.data_editor_group # Example
  }
}