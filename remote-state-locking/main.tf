provider "aws" {
  region  = var.region
}

locals {
  bucket_name = var.bucket_name
  dynamodb_table = var.dynamodb_table
}

################# CREATING THE REMOTE S3 BUCKET
resource "aws_s3_bucket" "remote-state" {
  bucket        = var.bucket_name
  acl           = "private"
  region        = var.region
  force_destroy = var.force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  versioning {
    enabled = var.versioning
  }
}

################# IAM POLICY FOR REMOTE S3 BUCKET
data "aws_iam_policy_document" "remote-state-policy-document" {
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "remote-state-policy" {
  name   = "remote-state-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.remote-state-policy-document.json
}






################# CREATING THE DYNAMODB STATE LOCK
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  read_capacity = var.capacity
  write_capacity = var.capacity
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

################# IAM POLICY FOR DYNAMO DB STATE LOCK
data "aws_iam_policy_document" "dynamodb-state-lock-document" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/${local.dynamodb_table}",
    ]
  }
}

resource "aws_iam_policy" "dynamodb-state-lock-policy" {
  name   = "dynamodb-state-lock"
  path   = "/"
  policy = data.aws_iam_policy_document.dynamodb-state-lock-document.json
}
