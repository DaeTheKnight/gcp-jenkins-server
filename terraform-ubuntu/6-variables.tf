variable "project" {
  description = "the GCP project ID"
  type        = string
}
variable "vpc" {
  description = "the vpc name"
  type        = string
}

variable "region" {
  description = "the region of the instance"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "the zone of the instance"
  type        = string
  default     = "us-central1-b"
}