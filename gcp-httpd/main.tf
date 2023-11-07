# Your code here
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.80.0"
    }
  }
}

provider "google" {
  # Configuration options
  region      = var.region
  project     = var.project
  zone        = var.zone
  credentials = file("../terraform.json")
}

resource "google_compute_network" "vpc_network" {
  project                 = var.project
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "public_subnetwork" {
  name = var.subnet_name
  project = var.project
  region = var.region
  ip_cidr_range = var.subnet_cidr
  network = google_compute_network.vpc_network.id

}

resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.instance_type
  zone         = var.zone

  tags = var.network_tags
  
  metadata_startup_script = "sudo apt-get update; sudo apt-get -y install apache2; sudo systemctl start apache2; sudo systemctl enable apache2"

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
    }
  }
  network_interface {
    #network = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.public_subnetwork.id

    access_config {
      //Ephemeral public IP
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = var.environment
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.network_tags
}