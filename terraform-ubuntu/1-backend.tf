terraform {
  backend "gcs" {
    bucket      = "state-ubuntu"
    prefix      = "terraform/state"
    credentials = "key.json"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
