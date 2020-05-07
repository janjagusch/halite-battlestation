locals {
  dataset_filepath = "../bigquery/datasets/benchmark"
  tables_filepath  = "${local.dataset_filepath}/tables"
  views_filepath   = "${local.dataset_filepath}/views"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id    = "benchmark"
  friendly_name = "benchmark"
  description   = "Stores configuration and results of benchmarking matches between agents."
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

# Tables
resource "google_bigquery_table" "table__matches" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "matches"
  schema     = file("${local.tables_filepath}/matches.json")
}

resource "google_bigquery_table" "table__actions" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "actions"
  schema     = file("${local.tables_filepath}/actions.json")
}

resource "google_bigquery_table" "benchmark__boards" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "boards"
  schema     = file("${local.tables_filepath}/boards.json")
}

resource "google_bigquery_table" "benchmark__units" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "units"
  schema     = file("${local.tables_filepath}/units.json")
}

resource "google_bigquery_table" "benchmark__players" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "players"
  schema     = file("${local.tables_filepath}/players.json")
}

# Views
module "view_matches_latest" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_latest"
}

module "view_players_latest" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_players_latest"
}

module "view_boards_latest" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_boards_latest"
}

module "view_units_latest" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_units_latest"
}

module "view_actions_latest" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_actions_latest"
}

module "view_units_created_deleted_at" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_units_created_deleted_at"
}

module "view_matches_agent_player_index" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_agent_player_index"
}

module "view_units_actions" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_units_actions"
}

module "view_ships_true_action" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_ships_true_action"
}

module "view_shipyards_true_action" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_shipyards_true_action"
}

module "view_true_actions" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_true_actions"

  # depends_on = [module.view_ships_true_action, module.view_shipyards_true_action]
}

module "view_matches_result" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_result"
}

module "view_matches_rank" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_rank"

  # depends_on = [module.view_matches_result]
}

module "view_matches_overview" {
  source = "../bigquery_view"

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_overview"

  # depends_on = [module.view_matches_result, module.view_matches_rank]
}


# Functions.
module "function_match_to_bigquery" {
  source = "../cloud_function"

  source_dir       = "../functions/match-to-bigquery"
  source_zip_dir   = var.source_zip_dir
  func_description = "Reads a match from a PubSub message and inserts it to BigQuery."
  topic_name       = "match"
  project_name     = var.project_id
  bucket_name      = var.bucket_name
}

module "function_match_to_storage" {
  source = "../cloud_function"

  source_dir       = "../functions/match-to-storage"
  source_zip_dir   = var.source_zip_dir
  func_description = "Reads a match from a PubSub message and dumps it in Cloud Storage."
  topic_name       = "match"
  project_name     = var.project_id
  bucket_name      = var.bucket_name
}
