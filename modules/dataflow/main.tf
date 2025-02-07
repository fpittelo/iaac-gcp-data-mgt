resource "google_dataflow_job" "dataflow_job" {
  project            = var.project
  region             = var.region

  name               = var.job_name
  temp_gcs_location  = var.temp_gcs_location
  template_gcs_path  = var.temp_gcs_path

  # Required parameters for the template (replace with your actual parameters)
  # These should match the parameters expected by your Dataflow template.
  parameters = {
    input_subscription = var.input_subscription != null ? var.input_subscription : null
    output_topic       = var.output_topic != null ? var.output_topic : null
    # ... other parameters
  }


  # Optional parameters
  # max_workers        = var.max_workers != null ? var.max_workers : null
  # machine_type       = var.machine_type != null ? var.machine_type : null
  # network            = var.network != null ? var.network : null
  # subnetwork         = var.subnetwork != null ? var.subnetwork : null
  # ... other optional parameters

  # Important: depends_on ensures the API is enabled before creating the job.
  depends_on = [google_project_service.dataflow_api]
}