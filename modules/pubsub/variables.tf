### ModulesVariables ###

variable "project_id" {
    description = "The GCP project ID"
    type        = string
}

variable "topic_name" {
    description = "The name of the Pub/Sub topic"
    type        = string
}

variable "labels" {
  type = map(string)
  description = "Labels to apply to resources"
  default = {}
}
