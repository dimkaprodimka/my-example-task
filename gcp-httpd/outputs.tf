output "instance_public_ip" {
  value = google_compute_instance.default.network_interface[*].access_config[*].nat_ip
}

output "instance_image_id" {
  value = google_compute_instance.default.boot_disk[*].initialize_params[*].image
}

output "instance_type" {
  value = google_compute_instance.default.machine_type
}

output "instance_network" {
  value = google_compute_network.vpc_network.id
}

output "instance_subnet" {
  value = google_compute_instance.default.network_interface[*].subnetwork
}

output "instance_zone" {
  value = google_compute_instance.default.zone
}
