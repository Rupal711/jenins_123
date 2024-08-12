resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_s3_object" "object" {
  bucket = "my-tf-test-bucket"
  key    = "index.html"
  source = "./index.html"
}
