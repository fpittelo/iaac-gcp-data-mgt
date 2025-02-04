resource "google_project_service" "bigquery_api" {
  project = var.project
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset
  project                     = var.project
  location                    = var.location

  access {
    role          = "roles/bigquery.dataOwner"
    user_by_email = var.owner_email # Replace with your email or service account
  }

  # Optional: Add more specific access controls
  # access {
  #   role          = "roles/bigquery.dataEditor"
  #   user_by_email = "another_user@example.com"
  # }

  # Optional: Description
  description = var.dataset_description != null ? var.dataset_description : "A BigQuery dataset"

  depends_on = [google_project_service.bigquery_api]
}

# Example of how to use the module:
# module "bigquery" {
#   project_id = "your-project-id"
#   dataset_id = "your_dataset_id"  # Or rely on the default
#   location   = "US" # Or rely on the default
#   owner_email = "your_email@example.com"
#   dataset_description = "My important dataset" # Optional
# }

output "dataset_self_link" {
  value = google_bigquery_dataset.dataset.self_link
  description = "The self link of the created dataset"
}