# modules/pubsub/main.tf
resource "google_pubsub_topic" "topic" {
  project = var.project_id
  name    = var.topic_name
  labels  = var.labels
}