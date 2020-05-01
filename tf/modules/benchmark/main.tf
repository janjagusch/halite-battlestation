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
resource "google_bigquery_table" "benchmark__units_created_deleted_at" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_units_created_deleted_at"
  view {
    query          = file("${local.views_filepath}/_units_created_deleted_at.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__matches_agent_player_index" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_agent_player_index"
  view {
    query          = file("${local.views_filepath}//_matches_agent_player_index.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__units_actions" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_units_actions"
  view {
    query          = file("${local.views_filepath}/_units_actions.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__ships_true_action" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_ships_true_action"
  view {
    query          = file("${local.views_filepath}/_ships_true_action.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__shipyards_true_action" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_shipyards_true_action"
  view {
    query          = file("${local.views_filepath}/_shipyards_true_action.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__true_actions" {
  dataset_id = "benchmark"
  table_id   = "_true_actions"
  view {
    query          = file("${local.views_filepath}/_true_actions.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__matches_result" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_result"
  view {
    query          = file("${local.views_filepath}/_matches_result.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__matches_rank" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_rank"
  view {
    query          = file("${local.views_filepath}/_matches_rank.sql")
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "benchmark__matches_overview" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "_matches_overview"
  view {
    query          = file("${local.views_filepath}/_matches_overview.sql")
    use_legacy_sql = false
  }
}

module "function_match_to_bigquery" {
  source = "./modules/cloud_functions"

  source_dir       = "../functions/match-to-bigquery"
  func_description = "Reads a match from a PubSub message and inserts it to BigQuery."
  topic_name       = "match"
  project_name     = var.project_id
  bucket_name      = var.bucket_name
}

module "function_match_to_storage" {
  source = "./modules/cloud_functions"

  source_dir       = "../functions/match-to-storage"
  func_description = "Reads a match from a PubSub message and dumps it in Cloud Storage."
  topic_name       = "match"
  project_name     = var.project_id
  bucket_name      = var.bucket_name
}
