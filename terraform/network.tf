# # Setup VPC.

# module "vpc" {
#   source                = "../modules/vpc"
#   vpc_cidr              = var.vpc_cidr
#   vpc_tags              = var.vpc_tags
#   azs                   = var.azs
#   private_subnets_cidrs = var.private_subnets_cidrs
#   public_subnets_cidrs  = var.public_subnets_cidrs
#   aws_region            = var.aws_region
# }