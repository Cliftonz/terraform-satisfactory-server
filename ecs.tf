
### --- ECS Cluster ---

resource "aws_ecs_cluster" "sat_ecs_cluster" {
  name = "satisfactory_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "sat_ecs_providers" {
  cluster_name = aws_ecs_cluster.sat_ecs_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.EC2_provider.name,
  ]
}

### --- ECS Providers ---
resource "aws_ecs_capacity_provider" "EC2_provider" {
  name = "ec2_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.sat_ec2_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 0
    }
  }
}

### --- ECS Service ---

resource "aws_ecs_service" "Satisfactory_Service" {
  name            = "satisfactory-service"
  cluster         = aws_ecs_cluster.sat_ecs_cluster.id
  task_definition = aws_ecs_task_definition.efs-sat-task.arn
  desired_count   = 1
  # TODO Dynamic type switch
  launch_type     =  "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    security_groups  = [aws_security_group.allow_sat_ports.id]
    subnets          = module.subnets.public_subnet_ids
    assign_public_ip = true
  }

  depends_on = [
    aws_security_group.allow_sat_ports,
    aws_ecs_cluster.sat_ecs_cluster,
    aws_ecs_task_definition.efs-sat-task
  ]

}

### --- ECS Task Definition ---

resource "aws_ecs_task_definition" "efs-sat-task" {
  family        = "Satisfactory-Server"
  requires_compatibilities = ["FARGATE","EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode = "awsvpc"
  provider = aws.primary
  execution_role_arn = module.role.id
  task_role_arn = module.role.id
  skip_destroy = false
  depends_on = [
    aws_cloudwatch_log_group.Satisfactory_Server,
    module.role
  ]

  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = module.sat_container_definition.json_map_encoded_list

  volume {
    name      = "satisfactory_volume"
    efs_volume_configuration {
      file_system_id = module.efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        iam = "ENABLED"
        access_point_id = element(module.efs.access_point_ids,0)
      }
    }
  }
}

### --- ECS Container Definition ---

module "sat_container_definition" {
  source = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_name = "satisfactory-server"
  container_image = "wolveix/satisfactory-server:latest"
  container_cpu = var.cpu * 1024
  container_memory = var.memory * 1024

  port_mappings = [
    {
      containerPort = "2049"
      hostPort      = "2049"
      protocol      = "tcp"
    },
    {
      containerPort = "7777"
      hostPort      = "7777"
      protocol      = "udp"
    },
    {
      containerPort = "15000"
      hostPort      = "15000"
      protocol      = "udp"
    },
    {
      containerPort = "15777"
      hostPort      = "15777"
      protocol      = "udp"
    },
  ]

  environment = [
    {
      name  = "AUTOPAUSE"
      value = true
    },
    {
      name  = "MAXPLAYERS"
      value = var.max_players
    },
    {
      name  = "NETWORKQUALITY"
      value = 3
    },
    {
      name  = "AUTOSAVENUM"
      value = 2
    },
    {
      name  = "AUTOSAVEONDISCONNECT"
      value = true
    },
    {
      name  = "AUTOSAVEINTERVAL"
      value = 180
    },
    {
      name  = "PUID"
      value = 1000
    },
    {
      name  = "PGID"
      value = 1000
    },
    {
      name  = "SKIPUPDATE"
      value = false
    },
    {
      name  = "STEAMBETA"
      value = false
    },
    {
      name  = "DEBUG"
      value = false
    }
  ]

  mount_points = [
    {
      "containerPath": "/config",
      "sourceVolume": "satisfactory_volume",
      "readOnly": false
    }
  ]

  log_configuration = {
    logDriver: "awslogs"
    options: {
      awslogs-group: "Satisfactory_Server",
      awslogs-region: var.region,
      awslogs-stream-prefix: local.appName
    }
  }

}




