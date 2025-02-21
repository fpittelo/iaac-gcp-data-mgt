variable "lake_name" {
  type = string
  description = "Name of the Dataplex lake"
}

variable "labels" {
  type = map(string)
  description = "Labels to apply to the lake"
}

variable "location" {
  type = string
  description = "Location of the lake"
}

variable "metastore_service" {
  type          = string
  description   = "Metastore service for the lake"
  default       = "DATAPLEX_ASSET"
}

variable "git_branch" {
  description = "The Github branch name"
  type        = string
}