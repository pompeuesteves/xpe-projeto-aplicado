variable "aws_region" {
  default = "us-east-2"
}

variable "account" {
  default = "713051429766"
}

variable "tags" {
  type = map(any)
  default = {
    IES       = "XPE"
    CURSO     = "EDC"
    Project   = "WEATHER"
    ManagedBy = "Terraform"
  }
}

variable "prefix" {
  default = "xpe"
}

variable "bucket_names" {
  description = "Create S3 buckets with these names"
  type        = list(string)
  default = [
    "script",
    "data"
  ]
}

variable "script_glue_bucket" {
  default = "xpe-script-713051429766-tf"
}

variable "data_glue_bucket" {
  default = "xpe-data-713051429766-tf"
}

variable "iam_role" {
  default = "arn:aws:iam::713051429766:role/AWSGlueServiceRole-IGTI-tf"
}

variable "rawzone_database" {
  default = "xpe-rawzone"
}

variable "refinedzone_database" {
  default = "xpe-refinedzone"
}

variable "glue_weather_extract" {
  default = "current_weather_extract"
}

variable "glue_weather_transform" {
  default = "current_weather_transform"
}

variable "name_role_glue" {
  default = "AWSGlueServiceRole-xpe-tf"
}

variable "name_policy_glue" {
  default = "AWSGluePolicy-xpe-tf"
}