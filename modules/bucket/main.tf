resource "google_storage_bucket" "bucket" {
  name                        = var.bucket
  location                    = var.location
  uniform_bucket_level_access = true # Enforce uniform bucket-level access
  force_destroy               = true # Allow Terraform to destroy non-empty bucket
  public_access_prevention = "enforced"

  versioning {
    enabled = var.versioning_enabled
  }
}