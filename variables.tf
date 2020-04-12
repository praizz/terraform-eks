variable "region" {
  default = "us-west-2"
}

variable "cluster-name" {
  description = "cluster-name"
  default = "test-eks-cluster-2"
}

variable "cidr-block" {
  description = "cidr-block"
  default = "10.0.0.0/16"
}

variable "private-subnets" {
  description = "private-subnets"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public-subnets" {
  description = "public-subnets"
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "bucket_name" {
  description = "the name to give the bucket"
  type        = string
  default     = "terraform-remote-state"
}

variable "dynamodb_table" {
  description = "the name to give the table"
  type        = string
  default     = "dynamodb-state-lock-10-05-2020"
}

variable "group-name" {
  description = "the group name for admin access"
  type        = string
  default     = "devops"
}

variable "group-members" {
  description = "the group policy name for group members"
  type        = string
  default     = "devops-members"
}

variable "programmatic-user" {
  description = "the name to give the user with access key and secret key"
  type        = string
  default     = "praise"
}

variable "console-user" {
  description = "the name to give the user with console access"
  type        = string
  default     = "obinna"
}

variable "pgp-key" {
  description = "the name to give the user with access key and secret key"
  type        = string
  default     = "keybase:cloudgirl"
}









