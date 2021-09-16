provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket  = "lab-terraform-julioamaral"
    key     = "terraform.tfstate"
    region  = "sa-east-1"
    encrypt = false
    profile = "lab-julio"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-fargate-data-prod"
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}
