data "aws_vpc" "selected" {
  id = "vpc-0f679b097590529d7"
}


# data "aws_subnet_ids" "subnets" {
#   vpc_id = data.aws_vpc.selected.id

#   tags = {
#     Tier = "Private"
#   }
# }

## EKS MODULE

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.0.2"
  
  # EKS CLUSTER
  cluster_version           = "1.22"
  vpc_id                    = data.aws_vpc.selected.id                              # Enter VPC ID
  private_subnet_ids        = local.private_subnet_ids   # Enter Private Subnet IDs

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_m5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium"]
      subnet_ids      = local.private_subnet_ids
      min_size        = "2"
      disk_size       = 20
    }
  }
}


module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.0.2"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # EKS Addons
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  # enable_amazon_eks_aws_ebs_csi_driver = true

  #K8s Add-ons
  enable_argocd                       = false
  enable_aws_for_fluentbit              = false
  enable_aws_load_balancer_controller = false
  enable_cluster_autoscaler           = false
  enable_metrics_server               = false
  enable_prometheus                   = false

  # depends_on = [
  #   module.eks_blueprints.managed_node_groups
  # ]
}


data "aws_eks_cluster" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}