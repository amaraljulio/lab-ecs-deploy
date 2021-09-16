aws_region = "sa-east-1"
vpc_cidr   = "10.33.0.0/16"
azs = [
  "sa-east-1a",
  "sa-east-1b",
  "sa-east-1c"
]
private_subnets_cidrs = [
  "10.33.0.0/20",
  "10.33.16.0/20",
  "10.33.32.0/20"
]
public_subnets_cidrs = [
  "10.33.48.0/20",
  "10.33.64.0/20",
  "10.33.80.0/20"
]
vpc_tags = {
  Name = "main"
}
