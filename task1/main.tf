terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "gcp-class5-5-420319"
  region      = "us-central1"
  zone        = "us-central-a"
  credentials = "gcp-class5-5-420319-bfb49f97b594.json"
}

resource "google_storage_bucket" "mmotion-notion" {
  name          = "mmotion-notion"
  location      = "us-central1"
  force_destroy = true

  website {
    main_page_suffix = "mmotion-index.html"
    not_found_page   = "404.html"
  }

  uniform_bucket_level_access = false
}

resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.mmotion-notion.name
  predefined_acl = "publicRead"
}

resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.mmotion-notion.name
  name         = each.value
  source       = "${path.module}/mmotion-index.html"
  content_type = "text/html"
}

// Public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for image files
resource "google_storage_bucket_object" "upload_images" {
  for_each     = fileset("${path.module}/", "*.jpg")
  bucket       = google_storage_bucket.mmotion-notion.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "image/jpeg"
}

// Public ACL for each image file
resource "google_storage_object_acl" "image_acl" {
  for_each       = google_storage_bucket_object.upload_images
  bucket         = google_storage_bucket_object.upload_images[each.key].bucket
  object         = google_storage_bucket_object.upload_images[each.key].name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/mmotion-notion/mmotion-index.html"
  description = "public access URL in GCP storage bucket details"
}
