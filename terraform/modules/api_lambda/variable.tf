variable "rest_api_id" {
  description = "API Gateway ID"
  type        = string
}

variable "rest_api_resource_id" {
  description = "API Gateway Resource ID"
  type        = string
}

variable "api_method" {
  description = "API Method"
  type        = string
}

variable "function_name" {
  description = "Lambda Function Name"
  type        = string
}

variable "role_arn" {
  description = "Lambda Role ARN"
  type        = string
}

variable "runtime" {
  description = "Lambda Runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "memory_size" {
  description = "Lambda Memory Size"
  type        = number
  default     = 128
}

variable "source_path" {
  description = "Lambda Source Path"
  type        = string
  default     = "../../dist"
}

variable "database_url" {
  description = "Database URL"
  type        = string
  default     = ""
}

variable "layers" {
  description = "Lambda Layers"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Lambda Environment Variables"
  type        = map(string)
  default     = {}
}

variable "authorizer_id" {
  description = "API Gateway Authorizer ID"
  type        = string
  default     = null
}
