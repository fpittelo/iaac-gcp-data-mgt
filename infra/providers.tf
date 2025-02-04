terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.17.0"
    }
  }
  backend "gcs" {
#   bucket    = "gothic-province-448810-q2-terraform"
    bucket    = var.bucket #map to Github secrets TF_VAR_BUCKET
    prefix    = "backend/terraform/state"
    use_oidc  = true
  }
}

provider "google" {
  project = var.project
  region  = var.location
  zone    = var.zone
}