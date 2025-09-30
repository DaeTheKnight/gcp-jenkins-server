data "google_compute_zones" "iowa" {
  region = "us-central1"
}

resource "google_compute_instance" "instance-1-iowa-1" {
  depends_on   = [google_compute_network.vpc]
  name         = "instance-1-iowa-1"
  machine_type = "e2-medium"
  zone         = data.google_compute_zones.iowa.names[0]

  tags = ["ubuntu-server-1"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
    }
  }

  #metadata_startup_script = file("jenkins-setup.sh")

  network_interface {
    network    = var.vpc
    subnetwork = google_compute_subnetwork.iowa-net-1.id
    access_config {
    }
  }
}
