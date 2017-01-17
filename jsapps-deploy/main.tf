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

resource "aws_launch_configuration" "app" {
	security_groups             = ["${var.cluster_security_group_id}"]
	key_name                    = "${var.keypair_name}"
	image_id                    = "${var.ecs_optimized_container_ami_id}"
	iam_instance_profile        = ""
	user_data                   = ""
	associate_public_ip_address = true
}

resource "aws_autoscaling_group" "app" {
  name                 = "am-${var.am_number}${var.cluster_iteration}-${var.node_env}-asg"
  vpc_zone_identifier  = ["${aws_subnet.main.*.id}"]
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.app.name}"
}
