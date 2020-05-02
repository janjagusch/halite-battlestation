variable "dataset_id" {
  type        = string
  description = "ID of the dataset"
}

variable "table_id" {
  type        = string
  description = "ID of the table"
}

variable "query_vars" {
  type        = map(string)
  description = "Variables to fill placeholders in query file"
  default     = {}
}
