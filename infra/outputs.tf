output "bucket" {
  value = module.cloud_storage_bucket.bucket_name
  description = "Name of the created bucket"
}

# outputs.tf (Exemple)
output "member_roles" {
  value = google_project_iam_member.multiple_roles
}