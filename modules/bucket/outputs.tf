# Outputs
output "bucket" {
  value = google_storage_bucket.bucket.name
}

output "bucket_url" {
  value = google_storage_bucket.bucket.self_link
}