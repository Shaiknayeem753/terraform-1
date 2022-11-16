terraform {
  backend "s3" {
    bucket = "bucket161120"
    key    = "path"
    region = "ap-south-1"
  }
}
