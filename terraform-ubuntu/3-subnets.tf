resource "google_compute_subnetwork" "iowa-net-1" {
  name                     = "iowa-net-1"
  ip_cidr_range            = "10.214.0.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}
