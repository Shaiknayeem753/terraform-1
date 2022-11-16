terraform {
  backend "s3" {
    bucket = "bucket161120"
    key    = "backend"
    region = "ap-south-1"
  }
}
