resource "google_compute_firewall" "allow-access-from-anywhere-to-ubuntu" {
  depends_on = [google_compute_network.vpc]
  name       = "allow-access-from-anywhere-to-ubuntu"
  network    = var.vpc

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "3389", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ubuntu-server-1", "ubuntu-server-3"]
}