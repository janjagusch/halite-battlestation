locals {
  source_zip_dir = "./.source_zip"
}


provider "google" {
  project = "kaggle-halite"
}

data "google_project" "kaggle_halite" {
  project_id = "kaggle-halite"
}

# Topics.
resource "google_pubsub_topic" "topic__leaderboard_request" {
  name = "leaderboard-request"
}

resource "google_pubsub_topic" "topic__leaderboard" {
  name = "leaderboard"
}

resource "google_pubsub_topic" "topic__match_request" {
  name = "match-request"
}

resource "google_pubsub_topic" "topic__match" {
  name = "match"
}

# Buckets.
resource "google_storage_bucket" "archive_bucket" {
  name     = "functions-archive"
  location = var.location
}

# Leaderboard infrastructure.
module "leaderboard" {
  source = "./modules/leaderboard"

  location        = var.location
  source_zip_dir  = local.source_zip_dir
  project_id      = data.google_project.kaggle_halite.project_id
  bucket_name     = google_storage_bucket.archive_bucket.name
  kaggle_username = var.kaggle_username
  kaggle_key      = var.kaggle_key
}

# Benchmark infrastructure.
module "benchmark" {
  source = "./modules/benchmark"

  location       = var.location
  source_zip_dir = local.source_zip_dir
  project_id     = data.google_project.kaggle_halite.project_id
  bucket_name    = google_storage_bucket.archive_bucket.name
}
