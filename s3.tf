resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.terraformbucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "publiceaccess" {
  bucket = aws_s3_bucket.terraformbucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.publiceaccess,
  ]

  bucket = aws_s3_bucket.terraformbucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.terraformbucket.id
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
}
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.terraformbucket.id
  key    = "error.html"
  source = "error.html"
  content_type = "text/html"
}

resource "aws_s3_object" "assets_folder" {
  for_each = fileset("assets", "**/*") 
  bucket = aws_s3_bucket.terraformbucket.id
  key    = each.key
  source = "assets/${each.key}" 
}

resource "aws_s3_object" "error_folder" {
  for_each = fileset("error_files", "**/*")  
  bucket = aws_s3_bucket.terraformbucket.id
  key    = each.key
  source = "error_files/${each.key}" 
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.terraformbucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "assets/"
    }
    redirect {
      replace_key_prefix_with = "assets/"
    }
  }
}
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.terraformbucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
   "Principal": "*",
      "Action": [ "s3:GetObject" ],
      "Resource": [
        "${aws_s3_bucket.terraformbucket.arn}",
        "${aws_s3_bucket.terraformbucket.arn}/*"
      ]
    }
  ]
}
EOF
}
