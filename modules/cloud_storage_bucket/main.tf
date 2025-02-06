resource "google_storage_bucket" "bucket" {
  name                        = var.bucket
  location                    = var.location
  uniform_bucket_level_access = true # Enforce uniform bucket-level access

  # Optional: Versioning
  versioning {
    enabled = var.versioning_enabled
  }

  # Optional: Encryption (example - Customer-managed encryption keys)
  # encryption {
  #   default_kms_key {
  #     resource_id = var.kms_key_id
  #   }
  # }

  # Optional: Public access prevention - recommended
  public_access_prevention = "enforced"

  # Optional: Fine-grained access control (if needed, use with care)
  # access_control_model = "fine-grained"
}

# Optional: Bucket IAM bindings (example)
resource "google_storage_bucket_iam_member" "bucket_owner" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectAdmin" # Or other appropriate role
  member = "user:${var.bucket_owner_email}" # Example: user email
}