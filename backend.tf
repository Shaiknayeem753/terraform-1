terraform {
  backend "s3" {
    bucket = "bucket161120"
    key    = "myserver1"
    region = "ap-south-1"
  }
}
