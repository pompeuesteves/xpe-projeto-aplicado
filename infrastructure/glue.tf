resource "aws_glue_job" "current_weather_extract" {
  name              = var.glue_weather_extract
  tags              = var.tags
  description       = "Glue Job from terraform: ${var.glue_weather_extract}"
  role_arn          = var.iam_role
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  max_retries       = 0
  timeout           = 30

  command {
    script_location = "s3://${var.prefix}-script-${var.account}-tf/scripts/${var.glue_weather_extract}.py"
    python_version  = "3"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-metrics"                   = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${var.prefix}-script-${var.account}-tf/sparkHistoryLogs/"
    "--TempDir"                          = "s3://${var.prefix}-script-${var.account}-tf/temporary/"
    "--enable-glue-datacatalog"          = ""
    "--class"                            = "GlueApp"
    "--api_key"                          = "fee18c66937a024decff4075740077e4"
    "--api_url"                          = "https://api.openweathermap.org/data/2.5/weather"
    "--bucket"                           = var.data_glue_bucket
    "--key"                              = "raw-zone/openweathermap"
  }
}


resource "aws_glue_job" "current_weather_transform" {
  name              = var.glue_weather_transform
  tags              = var.tags
  description       = "Glue Job from terraform: ${var.glue_weather_transform}"
  role_arn          = var.iam_role
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  max_retries       = 0
  timeout           = 30

  command {
    script_location = "s3://${var.prefix}-script-${var.account}-tf/scripts/${var.glue_weather_transform}.py"
    python_version  = "3"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-metrics"                   = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${var.prefix}-script-${var.account}-tf/sparkHistoryLogs/"
    "--TempDir"                          = "s3://${var.prefix}-script-${var.account}-tf/temporary/"
    "--enable-glue-datacatalog"          = ""
    "--class"                            = "GlueApp"
    "--bucket"                           = var.data_glue_bucket
    "--key"                              = "refined-zone/openweathermap"
  }
}


resource "aws_glue_catalog_database" "rawzone" {
  name        = var.rawzone_database
  description = "base de dados da camada raw"
  tags        = var.tags
}


resource "aws_glue_catalog_database" "refinedzone" {
  name        = var.refinedzone_database
  description = "base de dados da camada refined"
  tags        = var.tags
}