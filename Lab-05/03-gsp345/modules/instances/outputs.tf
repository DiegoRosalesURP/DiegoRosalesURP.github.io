output "instance_names" {
  description = "Nombres de las instancias creadas"
  value       = [google_compute_instance.tf-instance-1.name, google_compute_instance.tf-instance-2.name]
}

output "instance_ips" {
  description = "IPs internas de las instancias"
  value       = [google_compute_instance.tf-instance-1.network_interface[0].network_ip, google_compute_instance.tf-instance-2.network_interface[0].network_ip]
}

output "instance_zones" {
  description = "Zonas donde se crearon las instancias"
  value       = [google_compute_instance.tf-instance-1.zone, google_compute_instance.tf-instance-2.zone]
}