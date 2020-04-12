provider "aws" {
  region  = var.region
}

################# DATA SOURCES
data "aws_eks_cluster" "sample-cluster" {
  name = module.eks-sample-cluster.cluster_id
}

data "aws_eks_cluster_auth" "sample-cluster" {
  name = module.eks-sample-cluster.cluster_id
}

data "aws_availability_zones" "available" {
}


#this has to be there, it is the auth token that allows communication with eks-cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.sample-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.sample-cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.sample-cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

################# EKS CLUSTER
module "eks-sample-cluster" {
  source          = "./modules/terraform-aws-eks-master"
  cluster_name    = var.cluster-name
  subnets         = module.vpc.private_subnets      
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "t2.small"
      asg_max_size  = 5
      asg_min_size  = 1
      asg_desired_capacity = 1
    }
  ]
}

locals {
  cluster-name = var.cluster-name
  region = var.region
}

# run 'aws eks update-kubeconfig ...' locally and update local kube config
resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks-sample-cluster]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${local.cluster-name} --region ${local.region}"
  }
}


#################### HELM
resource "null_resource" "install_helm" {
  depends_on = [null_resource.update_kubeconfig]

  provisioner "local-exec" {
    command = "./scripts/install-helm.sh"
  }
}


#################### ALB INGRESS
# WARNING: can't destroy internet gateway when installed aws-alb-ingress-controller
# https://github.com/terraform-providers/terraform-provider-aws/issues/9101

resource "aws_iam_role_policy_attachment" "alb_ingress_policy_attachment" {
  role = module.eks-sample-cluster.worker_iam_role_name
  policy_arn = aws_iam_policy.alb_ingress_policy.arn
}

resource "aws_iam_policy" "alb_ingress_policy" {
  name = "alb-ingress-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:DescribeCertificate",
        "acm:ListCertificates",
        "acm:GetCertificate"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVpcs",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeRules",
        "elasticloadbalancing:DescribeSSLPolicies",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetGroupAttributes",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "null_resource" "install_aws_alb_ingress_controller" {
  depends_on = [null_resource.install_helm]

  # sleep 60 seconds and wait for helm tiller deployed
  provisioner "local-exec" {
    command = "sleep 60;helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator;helm install incubator/aws-alb-ingress-controller --set autoDiscoverAwsRegion=true --set autoDiscoverAwsVpcID=true --set clusterName=${local.cluster-name} --generate-name"
  }
}



####################### VPC MODULE
module "vpc" {
  source  = "./modules/terraform-aws-vpc-master"

  name                 = "test-vpc"
  cidr                 = var.cidr-block
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private-subnets
  public_subnets       = var.public-subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = false

  public_subnet_tags = {
    "kubernetes.io/cluster/var.cluster-name" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/var.cluster-name" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}


########################### USERS AND PERMISSIONS

############# CREATE GROUP
resource "aws_iam_group" "groups" {
  name = var.group-name
}

############# CREATE GROUP POLICY 
resource "aws_iam_group_policy_attachment" "groups-policy-attachment" {
    group = aws_iam_group.groups.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

############# CREATE USERS
######## Programmatic access (access key and secret key)
resource "aws_iam_user" "programmatic-user" {
  name = var.programmatic-user
  tags = {
    name = var.programmatic-user
  }
}

resource "aws_iam_access_key" "programmatic-user-access-key" {
  user    = aws_iam_user.programmatic-user.name
  pgp_key = var.pgp-key 
}

######## AWS Management Console access (username and password)
resource "aws_iam_user" "console-user" {
  name = var.console-user
  force_destroy = true
  tags = {
    name = var.console-user
  }
}
resource "aws_iam_user_login_profile" "console-user" {
  user    = aws_iam_user.console-user.name
  pgp_key = var.pgp-key
}

############# ATTACH USERS TO GROUP
resource "aws_iam_group_membership" "group-members" {
  name = var.group-members
  users = [
      aws_iam_user.programmatic-user.name,
      aws_iam_user.console-user.name
  ] 
  group = aws_iam_group.groups.name
}










