output "bucket" {
  value = module.google_storage_bucket.bucket
  description = "Name of the created bucket"
}

# outputs.tf (Exemple)
output "member_roles" {
  value = google_project_iam_member.multiple_roles
}

