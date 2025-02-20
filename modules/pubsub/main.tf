resource "google_pubsub_topic" "default" {
  for_each = var.topics
  name = each.value.name
  labels = each.value.labels

  message_storage_policy {
    allowed_persistence_regions = each.value.allowed_persistence_regions
  }

  kms_key_name = each.value.kms_key_name

  schema_settings {
    schema   = each.value.schema
    encoding = each.value.encoding
  }
  
}

resource "google_pubsub_subscription" "default" {
 for_each = var.subscriptions

  name  = each.value.name
  topic = each.value.topic

  labels = each.value.labels

  ack_deadline_seconds       = each.value.ack_deadline_seconds
  message_retention_duration = each.value.message_retention_duration
  retain_acked_messages      = each.value.retain_acked_messages
  
  filter = each.value.filter

  push_config {
    push_endpoint = each.value.push_endpoint
  }

  dead_letter_policy {
    dead_letter_topic     = each.value.dead_letter_topic
    max_delivery_attempts = each.value.max_delivery_attempts
  }

  expiration_policy {
    ttl = each.value.ttl
  }
  
}