output "bucket_name" {
  description = "Nombre del bucket creado"
  value       = google_storage_bucket.bucket.name
}

output "bucket_url" {
  description = "URL del bucket"
  value       = google_storage_bucket.bucket.url
}