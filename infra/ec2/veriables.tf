variable "region" {
  description = "The name of the aws Region"
  type        = string
  validation {
    condition     = length(var.region) > 0
    error_message = "Please provide aws region and try again"
  }
}


variable "envname" {
  description = "The name of the aws Environment"
  type        = string
  validation {
    condition     = length(var.envname) > 0
    error_message = "Please provide Backend Env name and try again"
  }
}

variable "bucket" {
  type        = string
  description = "The bucket name"
}
