output "bucket" {
  value = module.google_storage_bucket.bucket
  description = "Name of the created bucket"
}

# outputs.tf (Exemple)
output "member_roles" {
  value = google_project_iam_member.multiple_roles
}

output "dataset_self_links" {
  value = {
    for key, dataset in module.google_bigquery_dataset:
    key => dataset.dataset_self_link
  }
  description = "Self links of the created datasets"
}