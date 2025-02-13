###### varialbes.tf ######

variable "project_id" {
    description = "The GCP project ID"
    type        = string
}

variable "location" {
  description = "The location for the BigQuery dataset"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

/* variable "zone" {
    description = "The GCP zone"
    type        = string
} */

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}  # Set default to empty map if appropriate
}

variable "labels" {
  type = map(string)
  description = "Labels to apply to resources"
  default = {}
}

variable "member" {
  type = string
  description = "Adresse e-mail du membre à qui attribuer les rôles"
}

variable "roles" {
  type = list(string)
  description = "Liste des rôles à attribuer"
}

# Define variables for each environment (dev, qa, main)

variable "git_branch" {
   description = "The Github branch name"
   type        = string
}

variable "github_run_id" {
  description = "GitHub run ID"
  type        = string
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

####### Variables for GPC Cloud Storage #######

variable "bucket_name" {
  description = "The name of the Cloud Storage bucket"
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

variable "dataset_id" {
  description = "The BigQuery dataset ID"
  type        = string
}

variable "dataset_description" {
  description = "The description of the dataset"
  type        = string
  default     = null
}

variable "bucket_owner_email" {
  type = string
  description = "Email address of the bucket owner (for IAM)"
}

####### Variables for GPC BigQuery ####

/* variable "default_table_expiration_ms" {
  type = string
  description = "Default table expiration in milliseconds"
  default = "3600000"
} */

variable "dataset_owner_email" {
  type = string
  description = "The email of the user to grant dataOwner access"
  default = null
}

variable "data_viewer_group" {
  type = string
  description = "The email of the group to grant dataViewer access"
  default = null
}

variable "data_editor_group" {
  type = string
  description = "The email of the group to grant dataEditor access"
  default = null
}

variable "input_file_name" {
  type = string
  description = "The name of the input file"
  default = null
}

variable "input_folder" {
  type = string
  description = "The input folder for the Dataflow job"
  default = null
}

variable "output_folder" {
  type = string
  description = "The output folder for the Dataflow job"
  default = null
}

variable "temp_folder" {
  type = string
  description = "The temporary folder for the Dataflow job"
  default = null
}

variable "error_folder" {
  type = string
  description = "The error folder for the Dataflow job"
  default = null
}

variable "deletion_protection" {
  type = string
  description = "The error folder for the Dataflow job"
  default = null
}

####### Variables for GPC Dataflow ####

variable "job_name" {
    description = "The name of the Dataflow job"
    type        = string
}

variable "temp_gcs_location" {
    description = "The GCS location for temporary files"
    type        = string
}

variable "temp_gcs_path" {
    description = "The GCS path for temporary files"
    type        = string
}

variable "input_subscription" {
    description = "The Pub/Sub input subscription"
    type        = string
}

variable "output_topic" {
    description = "The Pub/Sub output topic"
    type        = string
}

variable "max_workers" {
    description = "The maximum number of workers"
    type        = string
}

#### APIGEE Variables ####

variable "apigee_org_id" {
  type = string
  description = "The Apigee Organization ID"
}

variable "apigee_env_name" {
  type = string
  description = "The Apigee Environment name"
}

variable "apigee_env_display_name" {
  type = string
  description = "The Apigee Environment display name"
}

variable "apigee_env_description" {
  type = string
  description = "The Apigee Environment description"
}

variable "apigee_env_deployment_type" {
  type = string
  description = "The Apigee Environment deployment type (PROXY or HYBRID)"
  default = "PROXY"
}

variable "apigee_min_node_count" {
  type = number
  description = "The minimum number of nodes for the Apigee environment"
  default = 1
}

variable "apigee_max_node_count" {
  type = number
  description = "The maximum number of nodes for the Apigee environment"
  default = 3 # Adjust as needed
}