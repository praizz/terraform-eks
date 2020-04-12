# terraform-eks
Terraform script that deploys AWS EKS with AWS VPC 
This folder contains Terraform configuration scripts that creates AWS EKS

## Prerequisites
```
aws-cli v1.16.226
kubectl v1.16.0
helm v2.14.3
terraform v0.12.16
```

# Configure AWS Credentials
$ aws configure
  ``` 
  AWS Access Key ID [****************7CDE]:
  AWS Secret Access Key [****************2NGa]:
  Default region name [eu-west-2]:
  Default output format [None]: 
  ```
## To create S3 and Dynamo DB for remote state and state locking
```
$ cd terraform-eks/remote-state-locking
$ terraform init
$ terraform plan
$ terraform apply
```
## Deploy the code for EKS Cluster and VPC
```
$ git clone https://github.com/praizz/terraform-eks
$ cd terraform-eks
$ terraform init
$ terraform plan
$ terraform apply
```
To destroy run 
```
$ terraform destroy
```
