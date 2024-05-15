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
/*region = "europe-north1"
zone = "europe-north1-a"*/
credentials = "gcp-class5-5-420319-bfb49f97b594.json"
}

resource "google_compute_network" "zeta-gundam0087-vpc" {
  project                 = "gcp-class5-5-420319"
  name                    = "zeta-gundam0087-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "zeta-gundam0087-subnet" {
  project                  = "gcp-class5-5-420319"
  name                     = "zeta-gundam0087-subnet"
  region                   = "europe-north1"
  ip_cidr_range            = "10.166.10.0/24"
  network                  = google_compute_network.zeta-gundam0087-vpc.id
}

resource "google_compute_firewall" "zeta-gundam0087-firewall-http" {
  project     = "gcp-class5-5-420319"
  name        = "zeta-gundam0087-firewall-http"
  network     = google_compute_network.zeta-gundam0087-vpc.id
    allow {
        protocol = "tcp"
        ports = ["80"] 
    }
    source_ranges = ["172.16.10.0/24","172.25.50.0/24","192.168.30.0/24"]
    target_tags = ["http-server"]
    priority = 600
}
# Europe Virtual Machine ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "zeta-gundam0087-vm" {
  name         = "zeta-gundam0087-vm"
  machine_type = "e2-medium"
  zone         = "europe-north1-a"
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
    network    = google_compute_network.zeta-gundam0087-vpc.id
    subnetwork = google_compute_subnetwork.zeta-gundam0087-subnet.id

    access_config {
      // Ephemeral IP
    }
  }
}
# Americas ----------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "gundam-zz0088-vpc" {
  project                 = "gcp-class5-5-420319"
  name                    = "gundam-zz0088-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "gundam-zz0088-subnet-a" {
  project                  = "gcp-class5-5-420319"
  name                     = "gundam-zz0088-subnet-a"
  region                   = "us-west1"
  ip_cidr_range            = "172.16.10.0/24"
  network                  = google_compute_network.gundam-zz0088-vpc.id
}

resource "google_compute_subnetwork" "victory-gundam0153-subnet-b" {
  project                  = "gcp-class5-5-420319"
  name                     = "victory-gundam0153-subnet-b"
  region                   = "southamerica-east1"
  ip_cidr_range            = "172.25.50.0/24"
  network                  = google_compute_network.gundam-zz0088-vpc.id
}

resource "google_compute_firewall" "gundam-zz0088-firewall-http" {
  project     = "gcp-class5-5-420319"
  name        = "gundam-zz0088-firewall-http"
  network     = google_compute_network.gundam-zz0088-vpc.id
    allow {
        protocol = "tcp"
        ports = ["3389"] 
    }
    source_ranges = ["0.0.0.0/0"]
    priority = 600
}
# Americas Virtual Machines ----------------------------------------------------------------------------------------------------------------------
resource "google_compute_instance" "gundam-zz0088-vm" {
  project      = "gcp-class5-5-420319"
  name         = "gundam-zz0088-vm"
  machine_type = "n2-standard-4"
  zone         = "us-west1-a"

   metadata = {
    startup-script = "    #!/bin/bash\n    apt-get update\n    apt-get install -y apache2\n    cat <<EOT > /var/www/html/index.html\n    <html>\n      <head>\n        <title>Welcome to My Homepage</title>\n      </head>\n      <body>\n        <h1>Welcome to My Homepage!</h1>\n        <p>This page is served by Apache on a Google Compute Engine VM instance.</p>\n      </body>\n    </html>"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415" 
      size  = 120
      type  = "pd-balanced"
    }
     mode = "READ_WRITE"
  }
     labels= {
        goog-ec-src = "vm_add-tf"
     }
  network_interface {
    network    = google_compute_network.gundam-zz0088-vpc.id
    subnetwork = google_compute_subnetwork.gundam-zz0088-subnet-a.id
 

    access_config {
      // Ephemeral IP
    }
  }
}

resource "google_compute_instance" "victory-gundam0153-vm" {
  name         = "victory-gundam0153-vm"
  machine_type = "n2-standard-4"
  zone         = "southamerica-east1-a"
  
    metadata = {
    startup-script = "    #!/bin/bash\n    apt-get update\n    apt-get install -y apache2\n    cat <<EOT > /var/www/html/index.html\n    <html>\n      <head>\n        <title>Welcome to My Armageddon Webpage</title>\n      </head>\n      <body>\n        <h1>Welcome to My Armageddon Homepage!</h1>\n        <p>I need coffee. Is it over, yet?</p>\n      </body>\n    </html>"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"  
      size  = 120
      type  = "pd-balanced"
    }
     mode = "READ_WRITE"
  }
     labels= {
        goog-ec-src = "vm_add-tf"
     }
  network_interface {
    network = google_compute_network.gundam-zz0088-vpc.id
    subnetwork = google_compute_subnetwork.victory-gundam0153-subnet-b.id
    access_config {
      // Ephemeral IP
    }
  }
}
#ASIA----------------------------------------------------------------------------------------------------
resource "google_compute_network" "gundam-wing0195-vpc" {
  project                 = "gcp-class5-5-420319"
  name                    = "gundam-wing0195-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "gundam-wing0195-subnet" {
  project                  = "gcp-class5-5-420319"
  name                     = "gundam-wing0195-subnet"
  region                   = "asia-east1"
  ip_cidr_range            = "192.168.30.0/24"
  network                  = google_compute_network.gundam-wing0195-vpc.id
}

resource "google_compute_firewall" "gundam-wing0195-firewall-rdp" {
  project     = "gcp-class5-5-420319"
  name        = "gundam-wing0195-firewall-rdp"
  network     = google_compute_network.gundam-wing0195-vpc.id
    allow {
        protocol = "tcp"
        ports = ["3389"] 
    }
    source_ranges = ["0.0.0.0/0"]
    priority = 600
}
#ASIA Virtural Machine----------------------------------------------------------------------------------------------------
resource "google_compute_instance" "gundam-wing0195-vm" {
  project      = "gcp-class5-5-420319"
  name         = "gundam-wing0195-vm"
  machine_type = "n2-standard-4"
  zone         = "asia-east1-a"
  
metadata = {
    startup-script = "    #!/bin/bash\n    apt-get update\n    apt-get install -y apache2\n    cat <<EOT > /var/www/html/index.html\n    <html>\n      <head>\n        <title>Welcome to My Armageddon Webpage</title>\n      </head>\n      <body>\n        <h1>Welcome to My Armageddon Homepage!</h1>\n        <p>I need coffee. Is it over, yet?</p>\n      </body>\n    </html>"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415" 
      size  = 120
      type  = "pd-balanced"
    }
     mode = "READ_WRITE"
  }
     labels= {
        goog-ec-src = "vm_add-tf"
     }
  network_interface {
    network = google_compute_network.gundam-wing0195-vpc.id
    subnetwork = google_compute_subnetwork.gundam-wing0195-subnet.id
    access_config {
      // Ephemeral IP
    }
  }
}
#Peering from Americas to Europe----------------------------------------------------------------------------------------------------
resource "google_compute_network_peering" "americas-to-europe-hq"{
    name = "americas-to-europe-hq"
    network = google_compute_network.gundam-zz0088-vpc.id
    peer_network = google_compute_network.zeta-gundam0087-vpc.id
    
}

resource "google_compute_network_peering" "europe-hq-to-americas"{ 
    name = "europe-hq-to-americas"
    network = google_compute_network.zeta-gundam0087-vpc.id
    peer_network = google_compute_network.gundam-zz0088-vpc.id
}
#VPN Gateway Asia to Europe----------------------------------------------------------------------------------------------------
resource "google_compute_vpn_gateway" "vpn-gateway-asia-to-europe" {
    name = "vpn-gateway-asia-to-europe"
    region = "asia-southeast1"
    network = google_compute_network.zeta-gundam0087-vpc.id
    
}

resource "google_compute_address" "static-ip-asia-to-europe" {
    name = "static-ip-asia-to-europe"
    region = "asia-southeast1"

}

resource "google_compute_vpn_tunnel" "tunnel-to-europe" {
    name = "tunnel-to-europe"
    peer_ip = google_compute_address.static-ip-europe-to-asia.address
    shared_secret = "glory-to-gallerhorn"
    target_vpn_gateway = google_compute_vpn_gateway.vpn-gateway-asia-to-europe.id

    local_traffic_selector = [google_compute_subnetwork.gundam-wing0195-subnet.ip_cidr_range]
    remote_traffic_selector = [google_compute_subnetwork.zeta-gundam0087-subnet.ip_cidr_range]

    depends_on = [
        google_compute_forwarding_rule.esp-to-asia,
        google_compute_forwarding_rule.to-asia-udp500,
        google_compute_forwarding_rule.to-asia-udp4500
    ]

}
#Forwarding Rules for Asia to Europe VPN
resource "google_compute_forwarding_rule" "esp-to-europe" {
    name = "esp-to-europe"
    ip_protocol = "ESP"
    ip_address = google_compute_address.static-ip-asia-to-europe.address
    target = google_compute_vpn_gateway.vpn-gateway-asia-to-europe.id
    region = "asia-southeast1"
}

resource "google_compute_forwarding_rule" "to-europe-udp500" {
    name = "to-europe-udp500"
    ip_protocol = "UDP"
    ip_address = google_compute_address.static-ip-asia-to-europe.address
    port_range = "500"
    target = google_compute_vpn_gateway.vpn-gateway-asia-to-europe.id
    region = "asia-southeast1"
}

resource "google_compute_forwarding_rule" "to-europe-udp4500" {
    name = "to-europe-udp4500"
    ip_protocol = "UDP"
    ip_address = google_compute_address.static-ip-asia-to-europe.address
    port_range = "4500"
    target = google_compute_vpn_gateway.vpn-gateway-asia-to-europe.id
    region = "asia-southeast1"
}

resource "google_compute_route" "asia-to-europe-route" {
    name = "asia-to-europe-route"
    network = google_compute_network.gundam-wing0195-vpc.id
    dest_range = "10.166.10.0/24"
    priority = 1000
    
    next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel-to-asia.id
}
# VPN Gateway Europe to Asia----------------------------------------------------------------------------------------------------
resource "google_compute_vpn_gateway" "vpn-gateway-europe-to-asia" {
    name = "vpn-gateway-europe-to-asia"
    region = "europe-north1"
    network = google_compute_network.gundam-wing0195-vpc.id
   
}

resource "google_compute_address" "static-ip-europe-to-asia" {
    name = "static-ip-europe-to-asia"
    region = "europe-north1"
}

resource "google_compute_vpn_tunnel" "tunnel-to-asia" {
    name = "tunnel-to-asia"
    peer_ip = google_compute_address.static-ip-asia-to-europe.address
    shared_secret = "glory-to-gallerhorn"
    target_vpn_gateway = google_compute_vpn_gateway.vpn-gateway-europe-to-asia.id
    
    local_traffic_selector = [google_compute_subnetwork.zeta-gundam0087-subnet.ip_cidr_range]
    remote_traffic_selector = [google_compute_subnetwork.gundam-wing0195-subnet.ip_cidr_range]

    depends_on = [
        google_compute_forwarding_rule.esp-to-europe,
        google_compute_forwarding_rule.to-europe-udp500,
        google_compute_forwarding_rule.to-europe-udp4500
     ]
}
#Forwarding Rules for Europe to Asia VPN
resource "google_compute_forwarding_rule" "esp-to-asia" {
    name = "esp-to-asia"
    ip_protocol = "ESP"
    ip_address = google_compute_address.static-ip-europe-to-asia.address
    target = google_compute_vpn_gateway.vpn-gateway-europe-to-asia.id
    region = "europe-north1"
}
 
resource "google_compute_forwarding_rule" "to-asia-udp500" {
    name = "to-asia-udp500"
    ip_protocol = "UDP"
    ip_address = google_compute_address.static-ip-europe-to-asia.address
    port_range = "500"
    target = google_compute_vpn_gateway.vpn-gateway-europe-to-asia.id
    region = "europe-north1"
}

resource "google_compute_forwarding_rule" "to-asia-udp4500" {
    name = "to-asia-udp4500"
    ip_protocol = "UDP"
    ip_address = google_compute_address.static-ip-europe-to-asia.address
    port_range = "4500"
    target = google_compute_vpn_gateway.vpn-gateway-europe-to-asia.id
    region = "europe-north1"
}

resource "google_compute_route" "europe-to-asia-route" {
    name = "europe-to-asia-route"
    network = google_compute_network.zeta-gundam0087-vpc.id
    dest_range = "192.168.30.0/24"
    priority = 1000
    
    next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel-to-europe.id
}













