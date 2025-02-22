###### Project Variables ######

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

variable "network" {
  description = "The network for the VM instance"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork for the VM instance"
  type        = string
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

####### Variables for GPC Cloud Storage #######

variable "bucket" {
  description = "The name of the Cloud Storage bucket"
  type        = string
}

variable "bucket_owner_email" {
  type = string
  description = "Email address of the bucket owner (for IAM)"
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

###### Variables for Bigquery ######

variable "datasets" {
  type = map(object({
    dataset_id                  = string
    description                 = string
    dataset_owner_email         = string
    delete_contents_on_destroy  = bool # Add this property
  }))
}
/* variable "owner_email" {
  description = "The email of the dataset owner"
  type        = string
} */

variable "service_account_email" {
  description = "The service account email for the VM instance"
  type        = string
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

####### Variables for GPC Dataplex ####
variable "lake_name" {
  type = string
  description = "The name of the Dataplex lake"
  default = null
}

variable "metastore_service_id" {
  description = "The Github branch name"
  type        = string
}
####### Variables for GPC Dataflow ####
variable "job_name" {
  type = string
  description = "Le nom du job Dataflow"
}

variable "template_gcs_path" {
  type = string
  description = "Le chemin GCS vers le template du job Dataflow"
}

variable "template_gcs_location" {
  type = string
  description = "L'emplacement GCS pour les fichiers temporaires"
}

variable "parameters" {
  type = map(string)
  description = "Paramètres du job Dataflow"
  default = {}
}

variable "on_delete" {
  type = string
  description = "Action à effectuer lors de la suppression du job (cancel ou drain)"
  default = "cancel"
}

variable "deletion_protection" {
  type = string
  description = "The error folder for the Dataflow job"
  default = null
}

variable "input_folder" {
  type = string
  description = "The input folder for the Dataflow job"
  default = null
}

variable "input_subscription" {
  type = string
  description = "The input subscription for the Dataflow job"
  default = null
}

variable "output_folder" {
  type = string
  description = "The output folder for the Dataflow job"
  default = null
}

variable "output_topic" {
  type = string
  description = "The output folder for the Dataflow job"
  default = null
}

variable "max_workers" {
  type = string
  description = "The maximum number of workers for the Dataflow job"
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