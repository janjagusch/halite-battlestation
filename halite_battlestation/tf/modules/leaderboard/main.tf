resource "google_bigquery_dataset" "dataset__leaderboard" {
  dataset_id    = "leaderboard"
  friendly_name = "leaderboard"
  description   = "Stores historical leaderboard of competition."
  project       = var.project_id
  location      = var.location

  access {
    role          = "WRITER"
    user_by_email = "haakon.robinson@gmail.com"
  }

  access {
    role          = "OWNER"
    user_by_email = "jan.jagusch@gmail.com"
  }
}

resource "google_bigquery_table" "table__leaderboard" {
  dataset_id = google_bigquery_dataset.dataset__leaderboard.dataset_id
  table_id   = "leaderboard"
  schema     = file("../bigquery/datasets/leaderboard/tables/leaderboard.json")
}

module "function__leaderboard_request" {
  source = "../cloud_function"

  source_dir       = "../functions/leaderboard-request"
  source_zip_dir   = var.source_zip_dir
  func_description = "Reads a leaderboard request from a PubSub message, requests the leaderboard from Kaggle and publishes it to a PubSub topic."
  topic_name       = "leaderboard-request"
  project_name     = var.project_id
  bucket_name      = var.bucket_name
  func_environment_variables = {
    KAGGLE_USERNAME = var.kaggle_username
    KAGGLE_KEY      = var.kaggle_key
  }
}

module "function__leaderboard_to_bigquery" {
  source = "../cloud_function"

  source_dir       = "../functions/leaderboard-to-bigquery"
  source_zip_dir   = var.source_zip_dir
  func_description = "Reads a leaderboard entry from a PubSub message and inserts it into BigQuery."
  topic_name       = "leaderboard"
  project_name     = var.project_id
  bucket_name      = var.bucket_name
}
