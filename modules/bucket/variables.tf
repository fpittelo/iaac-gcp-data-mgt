####### Variables for GPC Cloud Storage Bucket #######

variable "bucket_name" {
  description = "The name of the Cloud Storage bucket"
  type        = string
}

variable "location" {
  description = "The location for the BigQuery dataset"
  type        = string
}

/* variable "zone" {
    description = "The GCP zone"
    type        = string
} */

variable "project" {
    description = "The GCP project ID"
    type        = string
}

variable "versioning_enabled" {
  type = bool
  description = "Enable versioning for the bucket"
  default = false
}

variable "lifecycle_rule_age" {
  type = number
  description = "Age (in days) for lifecycle rule (example)"
  default = 30
}

# variable "kms_key_id" { # For CMEK
#   type = string
#   description = "KMS key ID for encryption (optional)"
#   default = null
# }

variable "bucket_owner_email" {
  type = string
  description = "Email address of the bucket owner (for IAM)"
}