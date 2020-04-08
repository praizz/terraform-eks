variable "region" {
  default = "us-west-2"
}

variable "cluster-name" {
  description = "cluster-name"
  default = "sample-cluster"
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