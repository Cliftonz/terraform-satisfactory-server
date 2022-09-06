
module "efs" {
  source = "cloudposse/efs/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version     = "0.32.7"

  namespace = local.namespace
  stage     = local.stage
  name      = local.appName
  region    = var.region
  vpc_id    = module.vpc.vpc_id
  subnets   = module.subnets.public_subnet_ids
  efs_backup_policy_enabled = var.data_backup
  throughput_mode = "bursting"
  transition_to_ia = ["AFTER_7_DAYS"]
  transition_to_primary_storage_class = ["AFTER_1_ACCESS"]

  allowed_security_group_ids = [aws_security_group.allow_sat_ports.id]

  additional_security_group_rules = [
    {
      type                     = "ingress"
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      cidr_blocks              = []
      source_security_group_id = module.vpc.vpc_default_security_group_id
      description              = "Allow ingress traffic to EFS from trusted Security Groups"
    }
  ]

  access_points = {
    "root" = {
    }
  }

  security_group_create_before_destroy = false

  lifecycle{
    prevent_destroy = var.prevent_data_deletion
  }

}


