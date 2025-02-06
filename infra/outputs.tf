output "bucket_name" {
  value = google_storage_bucket.default.name
  description = "Name of the created bucket"
}