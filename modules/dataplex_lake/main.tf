resource "google_dataplex_lake" "cygnus_lake" {
  name              = var.lake_name
  labels            = var.labels
  location          = var.location
  timeouts {
    create = "30m"
  }
}

resource "google_dataplex_zone" "raw_zone" {
  name              = "${var.lake_name}-raw"
  lake              = google_dataplex_lake.cygnus_lake.id
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
  lake              = google_dataplex_lake.cygnus_lake.id
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