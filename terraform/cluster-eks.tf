module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true

  vpc_id                   = "vpc-0583350d5965ee674"                                  //change for vpc id
  subnet_ids               = ["subnet-0abd773dd53d9621c", "subnet-04f4d0ddc008e26ec"] //change for subnet ids
  control_plane_subnet_ids = ["subnet-0abd773dd53d9621c", "subnet-04f4d0ddc008e26ec"] //change for subnet ids

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  self_managed_node_group_defaults = {
    use_mixed_instance_policy = {
      instances_distribution = {
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 10
        spot_allocation_strategy                 = "capacity-optimized"
      }

      override = [
        {
          instance_type     = "t3a.medium" // or set other instance type
          weighted_capacity = "1"
        },
        {
          instance_type     = "t3a.large" // or set other instance type
          weighted_capacity = "2"
        }
      ]
    }
  }

  self_managed_node_groups = {
    one = {
      name         = "eks-nodegroup"
      max_size     = 3
      desired_size = 1

      use_mixed_instance_policy = true
      instance_type             = "t3a.medium" // or set other instance type
    }
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t3a.medium", "t3a.large"] // or set other instance types
  }

  eks_managed_node_groups = {
    blue = {
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      instance_type = "t3a.medium"
    },
    green = {
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      instance_type = "t3a.medium"
      capacity_type = "SPOT"
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::532026769849:role/eks-node-role"
      username = "eks-node-role"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_users = [
    {
      rolearn  = "arn:aws:iam::532026769849:user/gustavo.peres@amlconsulting.com.br"
      username = "gustavo.peres@amlconsulting.com.br"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [
    "532026769849"
  ]
}