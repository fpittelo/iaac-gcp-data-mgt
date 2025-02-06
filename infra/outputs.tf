output "bucket" {
  value = module.cloud_storage_bucket.bucket_name
  description = "Name of the created bucket"
}