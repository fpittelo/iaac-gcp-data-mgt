### General Project variables values  ###
region                          = "europe-west6"
location                        = "europe-west6"
project_id                      = "iaac-gcp-data-mgt"
network                         = "default"
subnetwork                      = "default"
service_account_email           = "github-sa-dev@iaac-gcp-vm-dev.iam.gserviceaccount.com"
git_branch                      = "main"
github_run_id                   = ""
member                          = "serviceAccount:github-wif-sa@iaac-gcp-data-mgt.iam.gserviceaccount.com"
roles                           = [ 
  "roles/serviceusage.serviceUsageAdmin",
  "roles/bigquery.dataOwner",
  "roles/storage.objectAdmin" 
  ]
### Cloud Storage variables values  ###
bucket                          = "inputs-opr-data"
versioning_enabled              = true
lifecycle_rule_age              = 5
bucket_owner_email              = "frederic.pitteloud@gmail.com"
input_file_name                 = "readme.md"
input_folder                    = "input/readme.md"
output_folder                   = "output/output.txt"
temp_folder                     = "temp/temp.txt"
error_folder                    = "error/error.txt"
### BigQuery variables values   ###
datasets = {
  "DOMAIN_ACADEMIA" = {
    dataset_id                  = "DOMAIN_ACADEMIA"
    description                 = "Academia dataset"
    dataset_owner_email         = "frederic.pitteloud@gmail.com"
    delete_contents_on_destroy  = true
  },
  "DOMAIN_FINANCE" = {
    dataset_id                  = "DOMAIN_FINANCE"
    description                 = "Finance dataset"
    dataset_owner_email         = "frederic.pitteloud@gmail.com"
    delete_contents_on_destroy  = true
  },
  "DOMAIN_HR" = {
      dataset_id                  = "DOMAIN_HR"
      description                 = "HR dataset"
      dataset_owner_email         = "frederic.pitteloud@gmail.com"
      delete_contents_on_destroy  = true
    },
    "DOMAIN_OPERATIONS" = {
      dataset_id                  = "DOMAIN_OPERATIONS"
      description                 = "Operations dataset"
      dataset_owner_email         = "frederic.pitteloud@gmail.com"
      delete_contents_on_destroy  = true
    },
    "DOMAIN_PUBLIC" = {
      dataset_id                  = "DOMAIN_PUBLIC"
      description                 = "Public dataset"
      dataset_owner_email         = "frederic.pitteloud@gmail.com"
      delete_contents_on_destroy  = true
    },
    "DOMAIN_SHARED" = {
      dataset_id                  = "DOMAIN_SHARED"
      description                 = "Shared dataset"
      dataset_owner_email         = "frederic.pitteloud@gmail.com"
      delete_contents_on_destroy  = true
    }
    "DOMAIN_SANDBOX" = {
      dataset_id                  = "DOMAIN_SANDBOX"
      description                 = "Sandbox dataset"
      dataset_owner_email         = "frederic.pitteloud@gmail.com"
      delete_contents_on_destroy  = true
    }
}

# default_table_expiration_ms   = "3600000"
data_viewer_group               = "frederic.pitteloud@gmail.com"
data_editor_group               = "frederic.pitteloud@gmail.com"
### Dataflow variables values   ###
template_gcs_path               = ""
template_gcs_location           = ""
max_workers                     = ""
job_name                        = "dataflow-job"
input_subscription              = ""
output_topic                    = ""
####  Apigee variables values   ###
apigee_org_id                   = "data-mgt-org"
apigee_env_name                 = "main"
apigee_env_display_name         = "Production"
apigee_env_description          = "Production environment"
apigee_env_deployment_type      = "PROXY"
apigee_min_node_count           = 1
apigee_max_node_count           = 1