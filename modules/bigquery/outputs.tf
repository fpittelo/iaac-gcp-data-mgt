
output "dataset_self_link" {
  value = google_bigquery_dataset.dataset.self_link
  description = "The self link of the created dataset"
}