locals {
  query_file = "../bigquery/datasets/${var.dataset_id}/views/${var.table_id}.sql"
}


resource "google_bigquery_table" "view" {
  dataset_id = var.dataset_id
  table_id   = var.table_id
  view {
    query          = templatefile(local.query_file, var.query_vars)
    use_legacy_sql = false
  }
}
