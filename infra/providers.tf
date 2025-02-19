terraform {
  required_providers {
    google = {
      source    = "hashicorp/google"
      version   = "=6.20.0"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = "~> 2.0"
    }
  }
  
  backend "gcs" {
    bucket      = "iaac-gcp-data-mgt-terraform"
    prefix      = "backend/terraform/state"
  # use_oidc  = true
  }
}

provider "google" {
  project       = var.project_id
  region        = var.location
# zone          = var.zone
}

/* provider "google-beta" {
  project       = var.project_id
  region        = var.location
} */