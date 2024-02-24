// Creating S3 bucket

resource "aws_s3_bucket" "mybucket" {
  bucket = var.s3-bucketname

  tags = {
    Terraform = "True"
  }
}

resource "aws_s3_bucket_ownership_controls" "mybucket-ownership" {
  bucket = aws_s3_bucket.mybucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "mybucket-public-access" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "mybucket-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mybucket-ownership,
    aws_s3_bucket_public_access_block.mybucket-public-access,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "mybucket-object" {
  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"

  for_each = fileset("${path.module}/static-website/analog-clock/", "**/*")

  key    = each.value
  source = "${path.module}/static-website/analog-clock/${each.value}"

  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
    },
    split(".", each.value)[1],
    "application/octet-stream" # Default content type
  )

}

resource "aws_s3_bucket_website_configuration" "mybucket-web-config" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}