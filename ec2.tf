
### --- Launch Configuration ---

data "aws_ami" "aws_linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220805.0-x86_64-gp2"]
  }

  filter {
    name   = "id"
    values = ["ami-0c2ab3b8efb09f272"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_launch_configuration" "sat_ec2_conf" {
  name          = "sat_config"
  image_id      = data.aws_ami.aws_linux2.id
  instance_type = "t2.micro"
  # TODO only use if if ecs spot is active
  #spot_price = "0.001"
}

### --- Auto Scaling Groups ---

resource "aws_autoscaling_group" "sat_ec2_asg" {
  name                      = "satisfactory-server-scaler"
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 0
  force_delete              = true
  launch_configuration      = aws_launch_configuration.sat_ec2_conf.name
  vpc_zone_identifier       = module.subnets.availability_zone_ids

  timeouts {
    delete = "5m"
  }

}