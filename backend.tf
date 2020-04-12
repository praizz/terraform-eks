################# BACKEND RESOURCE
terraform {
 backend "s3" {
   encrypt = true
   bucket = "terraform-remote-state-09-05-2020"
   dynamodb_table = "dynamodb-state-lock-09-05-2020"
   region = "us-west-2"
   key = "terraform.tfstate"
 }
}