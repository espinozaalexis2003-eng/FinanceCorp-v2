
# Private S3 bucket for application deployment
resource "aws_s3_bucket" "application" {
  bucket_prefix = "financecorp-v2-app-"

  force_destroy = true

  tags = {
    Name    = "FinanceCorp-v2-App-Deployment"
    Project = "FinanceCorp-v2"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "application" {
  bucket = aws_s3_bucket.application.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "application" {
  bucket = aws_s3_bucket.application.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Require bucket ownership enforcement
resource "aws_s3_bucket_ownership_controls" "application" {
  bucket = aws_s3_bucket.application.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Upload application files from your computer
resource "aws_s3_object" "app_py" {
  bucket = aws_s3_bucket.application.id
  key    = "application/app.py"
  source = "${path.module}/app/app.py"

  etag = filemd5("${path.module}/app/app.py")
}

resource "aws_s3_object" "requirements" {
  bucket = aws_s3_bucket.application.id
  key    = "application/requirements.txt"
  source = "${path.module}/app/requirements.txt"

  etag = filemd5("${path.module}/app/requirements.txt")
}

# Upload Linux-compatible Python dependencies
resource "aws_s3_object" "python_wheels" {
  bucket = aws_s3_bucket.application.id
  key    = "application/financecorp-wheels.zip"

  source = "${path.module}/deployment/financecorp-wheels.zip"

  etag = filemd5(
    "${path.module}/deployment/financecorp-wheels.zip"
  )
}

