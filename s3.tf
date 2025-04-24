resource "random_string" "random_prefixes" {
  length = 6
  upper  = false
  special = false
}

resource "aws_s3_bucket" "sensitive_data" {
  bucket = "${var.unique_prefix}-sensitive-data-bucket-${random_string.random_prefixes.result}"
  force_destroy = true
}

resource "aws_s3_object" "sensitive_data_s3_object" {
  key    = "sensitive-data-s3-object"
  bucket = aws_s3_bucket.sensitive_data.id
  source = "1-MB-Test-SensitiveData.xlsx"
}