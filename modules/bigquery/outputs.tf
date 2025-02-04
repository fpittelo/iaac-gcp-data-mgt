output "dataset_self_link" {
  value       = module.bigquery_dataset.dataset_self_link # Corrected line
  description = "The self link of the created dataset"
}