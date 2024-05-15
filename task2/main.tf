terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  # Configuration options
project = "gcp-class5-5-420319"
region = "us-west1"
zone = "us-west1-a"
credentials = "gcp-class5-5-420319-bfb49f97b594.json"
}

resource "google_compute_network" "gundam0079-vpc" {
  project                 = "gcp-class5-5-420319"
  name                    = "gundam0079-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "gundam0079-subnet-a" {
  project                  = "gcp-class5-5-420319"
  name                     = "gundam0079-subnet-a"
  region                   = "us-west1"
  ip_cidr_range            = "10.166.10.0/24"
  network                  = google_compute_network.gundam0079-vpc.id
}

resource "google_compute_firewall" "allow-icmp" {
  project     = "gcp-class5-5-420319"
  name        = "gundam0079-firewall-icmp"
  network     = google_compute_network.gundam0079-vpc.id
    allow {
        protocol = "icmp" 
    }
    source_ranges = ["0.0.0.0/0"]
    priority = 600
}

resource "google_compute_firewall" "http" {
  project     = "gcp-class5-5-420319"
  name        = "gundam0079-firewall-http"
  network     = google_compute_network.gundam0079-vpc.id
    allow {
        protocol = "tcp"
        ports = ["80", "8080", "22", "3389"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http-server"]
    priority = 100
}

resource "google_compute_firewall" "https" {
  project     = "gcp-class5-5-420319"
  name        = "gundam0079-firewall-https"
  network     = google_compute_network.gundam0079-vpc.id
    allow {
        protocol = "tcp"
        ports = ["443"]
    }
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["https-server"]
    priority = 100
}
 
resource "google_compute_instance" "gundam0079-vm" {
  name         = "gundam0079-vm"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  tags         = ["http-server", "https-server"]

   metadata = {
    startup-script = "    #!/bin/bash\n    apt-get update\n    apt-get install -y apache2\n    cat <<EOT > /var/www/html/index.html\n    <html>\n      <head>\n        <title>Welcome to My Armageddon Webpage</title>\n      </head>\n      <body>\n        <h1>Welcome to My Armageddon Homepage!</h1>\n        <p>I need coffee. Is it over, yet?</p>\n      </body>\n    </html>"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.gundam0079-vpc.id
    subnetwork = google_compute_subnetwork.gundam0079-subnet-a.id

    access_config {
      // Ephemeral IP
    }
  }
}

output "vpc" {
  value       = google_compute_network.gundam0079-vpc.id
  description = "The ID of the VPC"
}

output "instance_public_ip" {
  value       = google_compute_instance.gundam0079-vm.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the web server"
}

output "instance_subnet" {
  value       = google_compute_instance.gundam0079-vm.network_interface[0].subnetwork
  description = "The subnet of the VM instance"
}

output "instance_internal_ip" {
  value       = google_compute_instance.gundam0079-vm.network_interface[0].network_ip
  description = "The internal IP address of the VM instance"
}
