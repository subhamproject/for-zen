variable "region" {
  description = "The name of the aws Region"
  type        = string
  validation {
    condition     = length(var.region) > 0
    error_message = "Please provide aws region and try again"
  }
}


variable "profile" {
  description = "The name of the aws Profile"
  type        = string
  validation {
    condition     = length(var.profile) > 0
    error_message = "Please provide AWS profile and try again"
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


variable "service" {
  description = "The name of the Amazon Service"
  type        = string
  validation {
    condition     = length(var.service) > 0
    error_message = "Please provide Service name you wish to deploy"
  }
}

variable "domain" {
  type        = string
  description = "Domain Name of Route53"
  validation {
    condition     = length(var.domain) > 0
    error_message = "Please provide Route53 Domain Name"
  }
}

variable "bucket" {
  type        = string
  description = "The bucket name"
}
