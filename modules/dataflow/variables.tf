### Modules Input Variables ###

variable "project" {
    description = "The GCP project ID"
    type        = string
}

variable "region" {
    description = "The region for the Dataflow job"
    type        = string
}

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