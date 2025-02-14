####### Variables for GPC Cloud Storage Bucket #######

variable "bucket" {
  description = "The name of the Cloud Storage bucket"
  type        = string
}

variable "location" {
  description = "The location for the BigQuery dataset"
  type        = string
}

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
variable "bucket_owner_email" {
  type = string
  description = "Email address of the bucket owner (for IAM)"
}