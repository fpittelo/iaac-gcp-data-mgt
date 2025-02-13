### Module for BigQuery Dataset ###
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset_id
  location                    = var.location
  description                 = var.dataset_description
  delete_contents_on_destroy  = true

# Add an owner role to ensure there is at least one owner
  access {
    role          = "roles/bigquery.dataOwner"
    user_by_email = var.dataset_owner_email # Ensure this variable is defined and set
  }
}