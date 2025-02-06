# Outputs
output "bucket_name" {
  value = google_storage_bucket.input_file.name
}

output "bucket_url" {
  value = google_storage_bucket.input_file.self_link
}