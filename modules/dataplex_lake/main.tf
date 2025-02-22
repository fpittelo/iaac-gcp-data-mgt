resource "google_dataplex_lake" "default" {
  name              = var.lake_name
  labels            = var.labels
  location          = var.location

    metastore {
      service         = "projects/${var.project_id}/locations/${var.location}/services/${var.metastore_service_id}"
  }
}

resource "google_dataplex_zone" "raw_zone" {
  name              = "${var.lake_name}-raw"
  lake              = google_dataplex_lake.default.id
  location          = var.location
  type              = "RAW"
  description       = "Raw data zone for the lake"
  labels            = var.labels
  resource_spec {
    location_type = "SINGLE_REGION"
  }
  discovery_spec {
    enabled = false
  }
}

resource "google_dataplex_zone" "curated_zone" {
  name              = "${var.lake_name}-curated"
  lake              = google_dataplex_lake.default.id
  location          = var.location
  type              = "CURATED"
  description       = "Curated data zone for the lake"
  labels            = var.labels
  resource_spec {
    location_type = "SINGLE_REGION"
  }
  discovery_spec {
    enabled = false
  }
}