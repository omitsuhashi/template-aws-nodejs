variable "api_name" {
  description = "API gateway name"
  type        = string
}

variable "description" {
  description = "API gateway description"
  type        = string
  default     = ""
}

variable "root_path" {
  description = "API gateway root path"
  type        = string
  default     = "api"
}
