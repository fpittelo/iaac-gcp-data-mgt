# Outputs
output "bucket" {
  value = google_storage_bucket.bucket.name
}

output "dataset_self_links" {
  value = { for key, dataset in module.google_bigquery_dataset: key => dataset.dataset_self_link }
  description = "Self links of the created datasets"
}

/* output "bucket_url" {
  value = google_storage_bucket.bucket.self_link
} */