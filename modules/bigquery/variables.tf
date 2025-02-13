### Modules Input Variables ###

variable "project" {
    description = "The GCP project ID"
    type        = string
}

variable "location" {
    description = "The location for the BigQuery dataset"
    type        = string
}

variable "dataset_id" {
    description = "The BigQuery dataset ID"
    type        = string
}

variable "dataset_description" {
    description = "The description of the dataset"
    type        = string
}

variable "data_viewer_group" {
    description = "The email of the group to grant dataViewer access"
    type        = string
}

variable "data_editor_group" {
    description = "The email of the group to grant dataEditor access"
    type        = string
}

#variable "default_table_expiration_ms" {
#   description = "The default table expiration in milliseconds"
#   type        = string
#}

variable "table_id" {
  type = string
  description = "ID of the BigQuery table (optional)"
  default = null
}

variable "table_schema" {
  type = string
  description = "Schema definition for the table (JSON string) (optional)"
  default = null
}

variable "table_expiration_time" {
  type = string
  description = "Table expiration time (optional)"
  default = null
}

variable "dataset_owner_email" {
  type = string
  description = "The email of the user to grant dataOwner access"
  default = null
}

variable "data_viewer_user" {
  type = string
  description = "The email of the user to grant dataViewer access"
  default = null
}

variable "data_editor_user" {
  type = string
  description = "The email of the user to grant dataEditor access"
  default = null
}