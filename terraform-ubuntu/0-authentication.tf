provider "google" {
  project     = var.project
  region      = "us-central1"
  credentials = file("key.json")
}