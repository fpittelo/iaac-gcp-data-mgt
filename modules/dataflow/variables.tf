### Modules Input Variables ###
variable "job_name" {
  type = string
  description = "Le nom du job Dataflow"
}

variable "template_gcs_path" {
  type = string
  description = "Le chemin GCS vers le template du job Dataflow"
}

variable "template_gcs_location" {
  type = string
  description = "L'emplacement GCS pour les fichiers temporaires"
}

variable "parameters" {
  type = map(string)
  description = "Paramètres du job Dataflow"
  default = {}
}

variable "on_delete" {
  type = string
  description = "Action à effectuer lors de la suppression du job (cancel ou drain)"
  default = "cancel"
}