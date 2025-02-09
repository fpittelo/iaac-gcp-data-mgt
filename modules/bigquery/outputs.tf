
output "dataset_self_link" {
  value = google_bigquery_dataset.dataset.self_link
  description = "The self link of the created dataset"
}

output "dataset_id" {
  value = google_bigquery_dataset.dataset.dataset_id
  description = "The ID of the created dataset"
}