### ModulesVariables ###
variable "topics" {
  type = map(object({
    name                       = string
    labels                     = map(string)
    allowed_persistence_regions = list(string)
    kms_key_name               = string
    schema                     = string
    encoding                   = string
  }))
  description = "Liste des topics Pub/Sub à créer"
  default     = {}
}

variable "subscriptions" {
  type = map(object({
    name                       = string
    topic                      = string
    labels                     = map(string)
    ack_deadline_seconds       = number
    message_retention_duration = string
    retain_acked_messages      = bool
    filter                     = string
    push_endpoint              = string
    dead_letter_topic          = string
    max_delivery_attempts      = number
    ttl                        = string
  }))
  description = "Liste des abonnements Pub/Sub à créer"
  default     = {}
}