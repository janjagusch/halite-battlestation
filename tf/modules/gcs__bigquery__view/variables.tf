variable "dataset__id" {
  type        = string
  description = "ID of the dataset"
}

variable "table__id" {
  type        = string
  description = "ID of the table"
}

variable "query__file" {
  type        = string
  description = "Path to the file containing the query"
}

variable "query__vars" {
  type        = object()
  description = "Variables to fill placeholders in query file"
  default     = ""
}