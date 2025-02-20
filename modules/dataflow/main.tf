resource "google_dataflow_job" "dataflow_job" {
  name               = var.job_name
  temp_gcs_location  = var.template_gcs_location
  template_gcs_path  = var.template_gcs_path
  parameters         = var.parameters

  on_delete          = var.on_delete
}