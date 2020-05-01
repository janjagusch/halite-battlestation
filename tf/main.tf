provider "google" {
  project = "kaggle-halite"
}

data "google_project" "kaggle_halite" {
  project_id = "kaggle-halite"
}

# Datasets.
resource "google_bigquery_dataset" "benchmark" {
  dataset_id    = "benchmark"
  friendly_name = "benchmark"
  description   = "Stores configuration and results of benchmarking matches between agents."
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
resource "google_bigquery_table" "benchmark__matches" {
  dataset_id = "benchmark"
  table_id   = "matches"
  schema     = file("../bigquery/datasets/benchmark/tables/matches.json")
}

resource "google_bigquery_table" "bechmark__actions" {
  dataset_id = "benchmark"
  table_id   = "actions"
  schema     = file("../bigquery/datasets/benchmark/tables/actions.json")
}

resource "google_bigquery_table" "benchmark__boards" {
  dataset_id = "benchmark"
  table_id   = "boards"
  schema     = file("../bigquery/datasets/benchmark/tables/boards.json")
}

resource "google_bigquery_table" "benchmark__units" {
  dataset_id = "benchmark"
  table_id   = "units"
  schema     = file("../bigquery/datasets/benchmark/tables/units.json")
}

resource "google_bigquery_table" "benchmark__players" {
  dataset_id = "benchmark"
  table_id   = "players"
  schema     = file("../bigquery/datasets/benchmark/tables/players.json")
}

# Views
resource "google_bigquery_table" "benchmark__units_created_deleted_at" {
  dataset_id = "benchmark"
  table_id   = "_units_created_deleted_at"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_units_created_deleted_at.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__matches_agent_player_index" {
  dataset_id = "benchmark"
  table_id   = "_matches_agent_player_index"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_matches_agent_player_index.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__units_actions" {
  dataset_id = "benchmark"
  table_id   = "_units_actions"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_units_actions.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__ships_true_action" {
  dataset_id = "benchmark"
  table_id   = "_ships_true_action"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_ships_true_action.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__shipyards_true_action" {
  dataset_id = "benchmark"
  table_id   = "_shipyards_true_action"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_shipyards_true_action.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__true_actions" {
  dataset_id = "benchmark"
  table_id   = "_true_actions"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_true_actions.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__matches_result" {
  dataset_id = "benchmark"
  table_id   = "_matches_result"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_matches_result.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__matches_rank" {
  dataset_id = "benchmark"
  table_id   = "_matches_rank"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_matches_rank.sql")
    use_legacy_sql = false
  }
}


resource "google_bigquery_table" "benchmark__matches_overview" {
  dataset_id = "benchmark"
  table_id   = "_matches_overview"
  view {
    query          = file("../bigquery/datasets/benchmark/views/_matches_overview.sql")
    use_legacy_sql = false
  }
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

# Functions.
resource "google_storage_bucket" "archive_bucket" {
  name     = "functions-archive"
  location = var.location
}

module "function_match_to_bigquery" {
  source = "./modules/cloud_functions"

  source_dir       = "../functions/match-to-bigquery"
  func_description = "Reads a match from a PubSub message and inserts it to BigQuery."
  topic_name       = "match"
  project_name     = data.google_project.kaggle_halite.project_id
  bucket_name      = google_storage_bucket.archive_bucket.name
}

module "function_match_to_storage" {
  source = "./modules/cloud_functions"

  source_dir       = "../functions/match-to-storage"
  func_description = "Reads a match from a PubSub message and dumps it in Cloud Storage."
  topic_name       = "match"
  project_name     = data.google_project.kaggle_halite.project_id
  bucket_name      = google_storage_bucket.archive_bucket.name
}

module "leaderboard" {
  source = "./modules/leaderboard"

  location        = var.location
  project_id      = data.google_project.kaggle_halite.project_id
  bucket_name     = google_storage_bucket.archive_bucket.name
  kaggle_username = var.kaggle_username
  kaggle_key      = var.kaggle_key
}
