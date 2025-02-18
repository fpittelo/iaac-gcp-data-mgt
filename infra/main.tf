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
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com",
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

resource "google_storage_bucket_object" "ac_schools" {
  bucket = "inputs-acd-data"  # Ou une variable si vous préférez
  name   = "inputs/ac_schools.csv"
  source = "./ac_schools.csv"  # Assurez-vous que le fichier existe localement
}

resource "google_storage_bucket_object" "opr_swissgrid_data" {
  bucket = var.bucket
  name   = "inputs/opr_swissgrid.csv" # Path within your bucket
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
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_HR"].dataset_id
  table_id                    = "hr_countries"
  deletion_protection         = false
  schema                      = <<-EOF
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
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_PUBLIC"].dataset_id
  table_id                    = "pub_epfl_students_data"
  deletion_protection         = false
  schema                      = <<-EOF
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
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_SHARED"].dataset_id
  table_id                    = "shr_epfl_employee_students_data"
  deletion_protection         = false
  schema                      = <<-EOF
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
    prevent_destroy = false
  }
}

resource "google_bigquery_table" "swissgrid_data" {
  dataset_id                  = module.google_bigquery_dataset["DOMAIN_OPERATIONS"].dataset_id
  deletion_protection         = false
  table_id                    = "opr_swissgrid_data"
  schema                      = <<-EOF
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

### Bigquery Transfer Configuration ###
resource "google_bigquery_data_transfer_config" "ac_schools_transfer" {
  display_name                      = "ac_schools_transfer"
  location                          = var.location
  data_source_id                    = "google_cloud_storage"
  destination_dataset_id            = module.google_bigquery_dataset["DOMAIN_ACADEMIA"].dataset_id
  schedule                          = "every 24 hours"

  params = {
    data_path_template              = "gs://inputs-acd-data/inputs/ac_schools.csv"
    destination_table_name_template = "ac_schools"
    file_format                     = "CSV"
    skip_leading_rows               = 1
    write_disposition               = "APPEND"
  }

  /* depends_on = [
    google_storage_bucket_object.ac_schools
  ] */
}

resource "google_bigquery_data_transfer_config" "swissgrid_transfer" {
  data_source_id                    = "google_cloud_storage"
  destination_dataset_id            = module.google_bigquery_dataset["DOMAIN_OPERATIONS"].dataset_id
  location                          = var.location
  display_name                      = "Swissgrid Data Transfer"
  schedule                          = "every 24 hours"

  params = {
    destination_table_name_template = "opr_swissgrid_data"
    data_path_template              = "gs://${var.bucket}/inputs/opr_swissgrid.csv"
    file_format                     = "CSV"
    skip_leading_rows               = 1
    write_disposition               = "APPEND"
  }

  depends_on = [
    google_storage_bucket_object.opr_swissgrid_data
  ]
}