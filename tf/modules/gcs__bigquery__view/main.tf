resource "google_bigquery_table" "view" {
  dataset_id = var.dataset__id
  table_id   = var.table__id
  view {
    query          = templatefile(var.query__file, var.query__vars)
    use_legacy_sql = false
  }
}
