variable "name" {
  description = "The name of the authorizer"
  type        = string
}

variable "rest_api_id" {
  description = "The ID of the associated REST API"
  type        = string
}

variable "source_path" {
  description = "The path to the source code"
  type        = string
  default     = "../../dist"
}

variable "role_arn" {
  description = "The role of the lambda"
  type        = string
}

variable "layers" {
  description = "The ARNs of the layers to be attached to the lambda"
  type        = list(string)
  default     = []
}

variable "runtime" {
  description = ""
  type        = string
  default     = "nodejs20.x"
}
