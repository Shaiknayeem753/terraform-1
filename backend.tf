terraform {
  backend "s3" {
    bucket = "mybucket161120"
    key    = "path"
    region = "ap-south-1"
  }
}
