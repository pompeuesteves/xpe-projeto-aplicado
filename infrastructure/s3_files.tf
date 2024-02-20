resource "aws_s3_object" "insert_scripts_extract" {
  bucket     = var.script_glue_bucket
  key        = "scripts/${var.glue_weather_extract}.py"
  acl        = "private"
  source     = "../scripts/${var.glue_weather_extract}.py"
  etag       = filemd5("../scripts/${var.glue_weather_extract}.py")
  depends_on = [aws_s3_bucket.buckets]
}

resource "aws_s3_object" "insert_scripts_transform" {
  bucket     = var.script_glue_bucket
  key        = "scripts/${var.glue_weather_transform}.py"
  acl        = "private"
  source     = "../scripts/${var.glue_weather_transform}.py"
  etag       = filemd5("../scripts/${var.glue_weather_transform}.py")
  depends_on = [aws_s3_bucket.buckets]
}