variable "name" {
  description = "Name of the Lambda"
}

variable "runtime" {
  type = string
}

variable "source_dir" {
  description = "Path to the source code for the Lambda"
  type        = string
}

variable "module_name" {
  description = "Name of the python module where the handler function lives"
  default     = ""
}

variable "description" {
  description = "Description of the Lambda function"
}

variable "environment_variables" {
  description = "Environment variables to pass to the Lambda"
  type        = map(string)
  default = {}
}

variable "timeout" {
  description = "The amount of time your Lambda function has to run in seconds"
  default     = 3
}

variable "memory_size" {
  type = number
}
