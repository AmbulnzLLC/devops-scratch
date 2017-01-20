provider "aws" {
	region = "${var.aws_region}"
}

data "aws_ami" "stable_coreos" {
  most_recent = true

  filter {
    name   = "description"
    values = ["CoreOS stable *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"] # CoreOS
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yaml")}"

  vars {
    aws_region         = "${var.aws_region}"
    ecs_cluster_name   = "${aws_ecs_cluster.main.name}"
    ecs_log_level      = "info"
    ecs_agent_version  = "latest"
  }
}

resource "aws_iam_instance_profile" "app" {
  name  = "tf-ecs-instprofile"
  roles = ["${aws_iam_role.app_instance.name}"]
}

resource "aws_iam_role" "app_instance" {
  name = "tf-ecs-example-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_launch_configuration" "app" {
	security_groups             = ["${var.cluster_security_group_id}"]
	key_name                    = "${var.keypair_name}"
	image_id                    = "${data.aws_ami.stable_coreos.id}"
  instance_type               = "${var.container_host_instance_type}"
	iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
	user_data                   = "${data.template_file.cloud_config.rendered}"	
  associate_public_ip_address = true
	lifecycle {
		create_before_destroy     = true
	}
}

resource "aws_autoscaling_group" "app" {
  name                 = "am-${var.am_number}${var.cluster_iteration}-${var.node_env}-asg"
  vpc_zone_identifier  = ["${var.vpc_subnets[0]}"]
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.app.name}"
}

resource "aws_ecs_cluster" "main" {
  name = "jsapps-am${var.am_number}${var.cluster_iteration}"
}

# Add load-balancer security group
resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "${var.vpc_id}"
  name   = "af-${var.am_number}${var.cluster_iteration}-lbsg"

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

# Add https target groups

# Add load balancer

# Add task
data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definition.json")}"

  vars {
    image_url        = "${var.task_url}"
    container_name   = "webrequester"
    port_num         = "${var.webrequester_port}"
  }
}

resource "aws_ecs_task_definition" "ghost" {
  family                = "jsapps_taskdef"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

# Add service
