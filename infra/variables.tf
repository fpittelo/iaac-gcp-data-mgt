###### varialbes.tf ######

variable "git_branch" {
   description = "The Github branch name"
   type        = string
}

variable "github_run_id" {
  description = "GitHub run ID"
  type        = string
}

variable "location" {
  description = "The location for the BigQuery dataset"
  type        = string
}

variable "zone" {
    description = "The GCP zone"
    type        = string
}

variable "project" {
    description = "The GCP project ID"
    type        = string
}

variable "dataset" {
  description = "The BigQuery dataset ID"
  type        = string
}

variable "dataset_description" {
  description = "The description of the dataset"
  type        = string
  default     = null
}

variable "owner_email" {
  description = "The email of the dataset owner"
  type        = string
}

variable "network" {
  description = "The network for the VM instance"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork for the VM instance"
  type        = string
}

variable "service_account_email" {
  description = "The service account email for the VM instance"
  type        = string
}

variable "owner_email" {
  description = "The service account email for the VM instance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}  # Set default to empty map if appropriate
}