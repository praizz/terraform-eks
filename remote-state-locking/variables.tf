variable "dynamodb_table" {
  description = "the name to give the table"
  type        = string
  default     = "dynamodb-state-lock-09-05-2020"
}

variable "capacity" {
  description = "tread and write capacity"
  default     = 20
}

variable "bucket_name" {
  description = "the name to give the bucket"
  type        = string
  default     = "terraform-remote-state-09-05-2020"
}

variable "versioning" {
  default     = true
  description = "enables versioning for objects in the S3 bucket"
  type        = bool
}

variable "region" {
  default    = "us-west-2"
  description = "Region where the S3 bucket will be created"
  type        = string
}

variable "force_destroy" {
  description = "Whether to allow a forceful destruction of this bucket"
  default     = false
  type        = bool
}

