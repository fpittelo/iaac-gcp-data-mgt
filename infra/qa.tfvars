### General Project variables values  ###
region                          = "europe-west6"
location                        = "europe-west6"
zone                            = "europe-west6-b"
project_id                      = "iaac-gcp-data-mgt"
owner_email                     = "frederic.pitteloud@gmail.com"
network                         = "default"
subnetwork                      = "default"
service_account_email           = "github-sa-dev@iaac-gcp-vm-dev.iam.gserviceaccount.com"
git_branch                      = "qa"
github_run_id                   = ""
### Cloud Storage variables values  ###
bucket                          = "iaac-gcp-data-mgt-data"
versioning_enabled              = true
lifecycle_rule_age              = 5
bucket_owner_email              = "frederic.pitteloud@gmail.com"
dataset_id                      = "iaac_gcp_data_mgt_dataset"
dataset_description             = "A BigQuery dataset for the IAAC GCP Data Management project" 
default_table_expiration_ms     = "3600000"
input_file_name                 = "readme.md"
input_folder                    = "input/readme.md"
output_folder                   = "output/output.txt"
temp_folder                     = "temp/temp.txt"
error_folder                    = "error/error.txt"
### BigQuery variables values  ###
dataset_owner_email            = "frederic.pitteloud@gmail.com"
data_viewer_group              = "frederic.pitteloud@gmail.com"
data_editor_group              = "frederic.pitteloud@gmail.com"
### Dataflow variables values  ###
temp_gcs_path                   = ""
temp_gcs_location               = ""
max_workers                     = ""
job_name                        = "dataflow-job"
input_subscription              = ""
output_topic                    = ""
####  Apigee variables values  ###
apigee_env                  = "qa"
apigee_env_display_name     = "Quality Assurance"
apigee_env_description      = "Quality Assurance environment"
apigee_env_deployment_type  = "PROXY"
apigee_min_node_count       = 1
apigee_max_node_count       = 1
services                    = [ "" ]