output "bucket" {
  value = google_storage_bucket.bucket.name
  description = "Name of the created bucket"
}