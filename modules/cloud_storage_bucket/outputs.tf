# Outputs
output "bucket_name" {
  value = google_storage_bucket.default.name
}

output "bucket_url" {
  value = google_storage_bucket.default.url
}