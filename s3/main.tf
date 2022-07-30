resource "aws_s3_bucket" "s3site" {
  bucket = var.bucket_name
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.s3site.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}


resource "aws_s3_bucket" "artifacts" {
  bucket = var.bucket_artifacts
  acl    = "private"
}
