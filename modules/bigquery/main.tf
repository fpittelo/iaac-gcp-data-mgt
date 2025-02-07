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

  # Add an owner role to ensure there is at least one owner
  access {
    role          = "roles/bigquery.dataOwner"
    user_by_email = var.dataset_owner_email # Ensure this variable is defined and set
  }
}