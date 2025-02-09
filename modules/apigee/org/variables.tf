variable "project_id" {
  description = "The project ID to enable the Apigee API"
  type        = string
}

variable "region" {
  description = "The region to create the Apigee organization in"
  type        = string
}

variable "analytics_region" {
  description = "The region to store analytics data in"
  type        = string
}

variable "apigee_org_id" {
  description = "The description of the Apigee organization"
  type        = string
}

variable "services" {
  type = list(string)
  default = ["apigee.googleapis.com", "compute.googleapis.com"]
}