### Grant the necessary permissions to the service account ###

resource "google_project_iam_member" "multiple_roles" {
  for_each = toset(var.roles)
  project = var.project_id
  role    = each.key
  member  = var.member
}

### Manages the service identity for Pub/Sub service ###
resource "google_project_service_identity" "df_pubsub_identity" {
  provider = google-beta
  service  = "pubsub.googleapis.com"
}

### Managing the service identity of a service ###
resource "google_project_service_identity" "df_dataflow_identity" {
  provider = google-beta
  service  = "dataflow.googleapis.com"
}

resource "google_project_service" "api_activations" {
  for_each = toset([
    "bigquery.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "compute.googleapis.com",
    "dataflow.googleapis.com",
    "datapipelines.googleapis.com",
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com",
    "dataplex.googleapis.com", # Dataplex API
    "datacatalog.googleapis.com", # Data Catalog API (Dataplex dependency)
    "datalineage.googleapis.com", # Data Lineage API (Optional, but commonly used)
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "google_project_iam_member" "service_account_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = var.bucket
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${var.service_account_email}"
  depends_on = [module.google_storage_bucket.google_storage_bucket]
}

resource "google_project_iam_member" "service_account_bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "bq_dataset_delete" {
  project = var.project_id
  role    = "roles/bigquery.dataOwner"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "service_account_bigquery_metadata_viewer" {
  project = var.project_id
  role    = "roles/bigquery.metadataViewer"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "bq_dataset_view" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${var.service_account_email}"
}

/* resource "google_project_iam_member" "dataplex_admin" {
  project = var.project_id
  role    = "roles/dataplex.admin"
  member  = "serviceAccount:${var.service_account_email}"
} */

resource "google_project_iam_member" "bigquery_data_transfer_service_agent" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:service-571690378641@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
}

#### Create GCP Cloud Storage bucket ####
module "google_storage_bucket" {
  source                    = "../modules/bucket"
  project                   = var.project_id
  bucket                    = var.bucket
  location                  = var.location
  versioning_enabled        = var.versioning_enabled
  bucket_owner_email        = var.bucket_owner_email  
}

# Create the HR data bucket
module "google_storage_bucket_inputs_hr_data" {
  source                = "../modules/bucket"
  project               = var.project_id
  bucket                = "inputs-hr-data"
  location              = var.location
  versioning_enabled    = var.versioning_enabled
  bucket_owner_email    = var.bucket_owner_email
}

# Create the Finance data bucket
module "google_storage_bucket_inputs_fin_data" {
  source                = "../modules/bucket"
  project               = var.project_id
  bucket                = "inputs-fin-data"
  location              = var.location
  versioning_enabled    = var.versioning_enabled
  bucket_owner_email    = var.bucket_owner_email
}

# Create the Academia data bucket
module "google_storage_bucket_inputs_acd_data" {
  source                = "../modules/bucket"
  project               = var.project_id
  bucket                = "inputs-acd-data"
  location              = var.location
  versioning_enabled    = var.versioning_enabled
  bucket_owner_email    = var.bucket_owner_email
}

# Create the Public data bucket
module "google_storage_bucket_inputs_pub_data" {
  source                = "../modules/bucket"
  project               = var.project_id
  bucket                = "inputs-pub-data"
  location              = var.location
  versioning_enabled    = var.versioning_enabled
  bucket_owner_email    = var.bucket_owner_email
}

# Create the Shared data bucket
module "google_storage_bucket_inputs_shr_data" {
  source                = "../modules/bucket"
  project               = var.project_id
  bucket                = "inputs-shr-data"
  location              = var.location
  versioning_enabled    = var.versioning_enabled
  bucket_owner_email    = var.bucket_owner_email
}
#### Upload the data to the buckets ####

provider "http" {}
  
data "http" "ac_schools" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/ac_schools.csv"
}

resource "google_storage_bucket_object" "ac_schools" {
  name                  = "inputs/ac_schools.csv"
  bucket                = "inputs-acd-data"
  content               = data.http.ac_schools.body
  depends_on            = [module.google_storage_bucket_inputs_acd_data]
  }                   

data "http" "ac_students_list" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/ac_students_list.csv"
}

resource "google_storage_bucket_object" "ac_students_list" {
  name                  = "inputs/ac_students_list.csv"
  bucket                = "inputs-acd-data"
  content               = data.http.ac_students_list.body
  depends_on            = [module.google_storage_bucket_inputs_acd_data]
}    

data "http" "hr_countries" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/hr_countries.csv"
}

resource "google_storage_bucket_object" "hr_countries" {
  name                  = "inputs/hr_countries.csv"
  bucket                = "inputs-hr-data"
  content               = data.http.hr_countries.body
  depends_on            = [module.google_storage_bucket_inputs_hr_data]
}

data "http" "hr_employees_list" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/hr_employees_list.csv"
}

resource "google_storage_bucket_object" "hr_employees_list" {
  name                  = "inputs/hr_employees_list.csv"
  bucket                = "inputs-hr-data"
  content               = data.http.hr_employees_list.body
  depends_on            = [module.google_storage_bucket_inputs_hr_data]
}

data "http" "hr_salaries" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/hr_salaries.csv"
}

resource "google_storage_bucket_object" "hr_salaries" {
  name                  = "inputs/hr_salaries.csv"
  bucket                = "inputs-hr-data"
  content               = data.http.hr_salaries.body
  depends_on            = [module.google_storage_bucket_inputs_hr_data]
}

data "http" "fin_students_fees" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/fin_students_fees.csv"
}

resource "google_storage_bucket_object" "fin_students_fees" {
  name                  = "inputs/fin_students_fees.csv"
  bucket                = "inputs-fin-data"
  content               = data.http.fin_students_fees.body
  depends_on            = [module.google_storage_bucket_inputs_fin_data]
}

data "http" "pub_epfl_student_data" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/pub_epfl_student_data.csv"
}

resource "google_storage_bucket_object" "pub_epfl_student_data" {
  name                  = "inputs/pub_epfl_student_data.csv"
  bucket                = "inputs-pub-data"
  content               = data.http.pub_epfl_student_data.body
  depends_on            = [module.google_storage_bucket_inputs_pub_data]
}

data "http" "shr_epfl_employee_student_data" {
  url = "https://raw.githubusercontent.com/fpittelo/iaac-gcp-data-mgt/refs/heads/main/files/shr_epfl_employee_student_data.csv"
}

resource "google_storage_bucket_object" "shr_epfl_employee_student_data" {
  name                  = "inputs/shr_epfl_employee_student_data.csv"
  bucket                = "inputs-shr-data"
  content               = data.http.shr_epfl_employee_student_data.body
  depends_on            = [module.google_storage_bucket_inputs_shr_data]
}

resource "null_resource" "create_opr_swissgrid_csv" {
  provisioner "local-exec" {
    command = <<EOT
      curl -s -L https://www.uvek-gis.admin.ch/BFE/ogd/103/ogd103_stromverbrauch_swissgrid_lv_und_endv.csv -o ${path.module}/opr_swissgrid.csv
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "google_storage_bucket_object" "opr_swissgrid_data" {
  bucket = var.bucket
  name   = "inputs/opr_swissgrid.csv" # Paath within your bucket
  depends_on = [ null_resource.create_opr_swissgrid_csv ]
  source = "${path.module}/opr_swissgrid.csv"  # Create swissgrid.csv 
  lifecycle {
    ignore_changes = [ detect_md5hash ]
  }
}

### BigQuery Deployment ###
module "google_bigquery_dataset" {
  for_each                    = var.datasets
  source                      = "../modules/bigquery"
  project                     = var.project_id
  location                    = var.location
  dataset_id                  = each.value.dataset_id
  delete_contents_on_destroy  = each.value.delete_contents_on_destroy
  dataset_owner_email         = each.value.dataset_owner_email
  depends_on = [ 
    google_project_iam_member.service_account_bigquery_admin,
    google_project_iam_member.bq_dataset_delete,
   ]
}

###   BigQuery Tables   ###
resource "google_bigquery_table" "ac_schools" {
  dataset_id                = module.google_bigquery_dataset["DOMAIN_ACADEMIA"].dataset_id
  table_id                    = "ac_schools"
  deletion_protection         = false
  schema                      = <<-EOF
  [
    {
      "name": "uid_schools",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "schools",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "ac_students" {
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_ACADEMIA"].dataset_id
  table_id                    = "ac_students_list"
  deletion_protection         = false
  schema                      = <<-EOF
  [
    {
      "name": "uid_students",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "students_id",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "phone",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "email",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "address",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "country",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "uid_schools",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "fin_students_fees" {
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_FINANCE"].dataset_id
  table_id                    = "fin_students_fees"
  deletion_protection         = false
  schema                      = <<-EOF
  [
    {
      "name": "uid_transaction",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "transaction_id",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "students_id",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "subscription_year",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "subscription",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "amount",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "revenue_stream",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "payment_status",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "hr_employees_list" {
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_HR"].dataset_id
  table_id                    = "hr_employees_list"
  deletion_protection         = false
  schema                      = <<-EOF
  [
    {
      "name": "uid_employees",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "phone",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "email",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "address",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "country",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "hr_salaries" {
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_HR"].dataset_id
  table_id                    = "hr_salaries"
  deletion_protection         = false
  schema                      = <<-EOF
  [
    {
      "name": "uid_salaries",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "salaries",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "hr_countries" {
  dataset_id            = module.google_bigquery_dataset["DOMAIN_HR"].dataset_id
  table_id              = "hr_countries"
  deletion_protection   = false
  schema                = <<-EOF
  [
    {
      "name": "uid_countries",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "country",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "Continent",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "pub_epfl_students_data" {
  dataset_id            = module.google_bigquery_dataset["DOMAIN_PUBLIC"].dataset_id
  table_id              = "pub_epfl_students_data"
  deletion_protection   = false
  schema                = <<-EOF
  [
    {
      "name": "year",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "student_count",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "department",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "phd_student_count",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "average_age",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "international_percentage",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "country",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "continent",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "shr_epfl_employee_students_data" {
  dataset_id            = module.google_bigquery_dataset["DOMAIN_SHARED"].dataset_id
  table_id              = "shr_epfl_employee_students_data"
  deletion_protection   = false
  schema                = <<-EOF
  [
    {
      "name": "year",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "student_count",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "employee_count",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy     = false
  }
}

resource "google_bigquery_table" "swissgrid_data" {
  dataset_id            = module.google_bigquery_dataset["DOMAIN_OPERATIONS"].dataset_id
  deletion_protection   = false
  table_id              = "opr_swissgrid_data"
  schema                = <<-EOF
  [
    {
      "name": "Datum",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "Date of the data"
    },
    {
      "name": "Landesverbrauch_GWh",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "National consumption in GWh"
    },
    {
      "name": "Endverbrauch_GWh",
      "type": "STRING",
      "mode": "NULLABLE",
      "description": "Final consumption in GWh"
    }
  ]
  EOF
  lifecycle {
    prevent_destroy = false
  }
}

### Dataplex Lake Deployment ###
resource "google_dataplex_lake" "cygnus_lake" {
  location              = var.location
  name                  = var.lake_name
  description           = "Data Management Lake"
  project               = var.project_id
  labels                = var.labels
}

resource "google_dataplex_zone" "raw_zone" {
  name                  = "${var.lake_name}-raw"
  lake                  = google_dataplex_lake.cygnus_lake.id
  location              = var.location
  type                  = "RAW"
  description           = "Raw data zone for the lake"
  labels                = var.labels
  resource_spec {
    location_type = "SINGLE_REGION"
  }
  discovery_spec {
    enabled = false
  }
}

resource "google_dataplex_zone" "curated_zone" {
  name                  = "${var.lake_name}-curated"
  lake                  = google_dataplex_lake.cygnus_lake.id
  location              = var.location
  type                  = "CURATED"
  description           = "Curated data zone for the lake"
  labels                = var.labels
  resource_spec {
    location_type       = "SINGLE_REGION"
  }
  discovery_spec {
    enabled             = false
  }
}

resource "google_dataplex_asset" "raw_bucket_asset" {
  count                 = length(var.raw_data_bucket_names)
  name                  = "raw-bucket-assets-${count.index + 1}"
  location              = var.location
  lake                  = google_dataplex_lake.cygnus_lake.id
  description           = "GCS bucket asset for raw data - ${element(var.raw_data_bucket_names, count.index)}"
  dataplex_zone         = google_dataplex_zone.raw_zone.id
  resource_spec {
    name = "projects/${var.project_id}/buckets/${element(var.raw_data_bucket_names, count.index)}"
    type = "STORAGE_BUCKET"
  }
  discovery_spec {
    enabled             = true
    schedule            = "0 * * * *" # Hourly discovery
    csv_options {
      header_rows       = 1
      encoding          = "UTF-8"
      delimiter         = ","
    }
    json_options {
      encoding          = "UTF-8"
    }
    include_patterns    = ["**/*.csv", "**/*.json"]
    exclude_patterns    = ["**/*.tmp"]
  }
  labels                = var.labels
}

resource "google_dataplex_asset" "bigquery_asset" {
  for_each              = var.datasets
# name                  = "bq-asset-${each.value.dataset_id}"
  name                  = "bq-asset-${lower(replace(each.value.dataset_id, "_", "-"))}"
  location              = var.location
  lake                  = google_dataplex_lake.cygnus_lake.id
  description           = "BigQuery dataset asset - ${each.value.dataset_id}"
  dataplex_zone         = google_dataplex_zone.curated_zone.id
  
  resource_spec {
    type                = "BIGQUERY_DATASET"
    name                = "projects/${var.project_id}/datasets/${each.value.dataset_id}"
  }
  discovery_spec {
    enabled             = true
    schedule            = "0 * * * *" # Hourly discovery
  }

  labels                = var.labels
}

/* ### Dataflow Deployment ###
module "dataflow_job" {
  source                            = "../modules/dataflow"
  job_name                          = "dataflow-job"
  template_gcs_location             = var.template_gcs_location
  template_gcs_path                 = var.template_gcs_path
  parameters                        = var.parameters
} */
