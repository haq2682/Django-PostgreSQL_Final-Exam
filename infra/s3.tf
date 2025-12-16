resource "aws_s3_bucket" "my_terraform_states" {
  bucket = "my-terraform-states"
  region = "us-east-1"
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}


terraform {
  backend "s3" {
    bucket         = "my-terraform-states"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
