
### --- Satisfactory VPC ---

module "vpc" {
  source    = "cloudposse/vpc/aws"
  version   = "1.1.1"
  namespace = local.namespace
  name      = local.appName
  stage     = local.stage

  cidr_block = local.ipv4_cidr
  assign_generated_ipv6_cidr_block = false
  internet_gateway_enabled = true

  #context = module.this.context
}

### --- VPC Subnets ---
module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"

  version = "2.0.3"
  namespace           = local.namespace
  stage               = local.stage
  name                = local.appName
  vpc_id              = module.vpc.vpc_id
  igw_id              = [module.vpc.igw_id]
  ipv4_enabled = true
  ipv4_cidr_block     = [local.ipv4_cidr]
  ipv6_enabled = false

  public_route_table_enabled = true
  private_subnets_enabled = false
  private_route_table_enabled = false

  nat_instance_enabled = false

  availability_zones  = [
    format("%s",var.region,"a"),
    format("%s",var.region,"b"),
    format("%s",var.region,"c"),
  ]
}

## --- Security Groups ---
### --- Allow Satisfactory port access ---
resource "aws_security_group" "allow_sat_ports" {
  name        = "fargate-satisfactory-sg"
  description = "Allow ports 7777,15000,15777 udp for inbound game traffic, and 2049 tcp for efs access."
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "efs access"
    protocol    = 6
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Game Port"
    protocol    = 17
    from_port   = 7777
    to_port     = 7777
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Beacon Port"
    protocol    = 17
    from_port   = 15000
    to_port     = 15000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Query Port. Port to enter the game when you first connect."
    protocol    = 17
    from_port   = 15777
    to_port     = 15777
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow the container to go anywhere it need to for updates and communications."
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
