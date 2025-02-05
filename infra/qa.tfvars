bucket                          = "iaac-gcp-data-mgt-data"
location                        = "europe-west6"
zone                            = "europe-west6-b"
project                         = "iaac-gcp-data-mgt"
dataset_id                      = "iaac_gcp_data_mgt_dataset"
dataset_description             = "A BigQuery dataset for the IAAC GCP Data Management project" 
owner_email                     = "frederic.pitteloud@gmail.com"
network                         = "default"
subnetwork                      = "default"
service_account_email           = "github-sa-dev@iaac-gcp-vm-dev.iam.gserviceaccount.com"
git_branch                      = "qa"
github_run_id                   = ""
### Cloud Storage variables ###
versioning_enabled              = true
lifecycle_rule_age              = 5
bucket_owner_email              = "frederic.pitteloud@gmail.com"
default_table_expiration_ms     = "3600000"
### BigQuery variables       ###
data_viewer_user               = "frederic.pitteloud@gmail.com"
data_editor_user               = "frederic.pitteloud@gmail.com"
data_viewer_group              = "frederic.pitteloud@gmail.com"
data_editor_group              = "frederic.pitteloud@gmail.com"