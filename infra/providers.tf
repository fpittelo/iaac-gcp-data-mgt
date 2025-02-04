terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.17.0"
    }
  }
  
  backend "gcs" {
    bucket    = "iaac-gcp-data-mgt-terraform"
    prefix    = "backend/terraform/state"
  # use_oidc  = true
  }
}

provider "google" {
  project = var.project
  region  = var.location
  zone    = var.zone
}