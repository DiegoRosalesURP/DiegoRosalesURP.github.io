resource "google_storage_bucket" "bucket" {
  name                        = "tf-bucket-821769"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  project                     = var.project_id
}