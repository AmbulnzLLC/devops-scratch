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
	iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
	user_data                   = "${data.template_file.cloud_config.rendered}"	associate_public_ip_address = true
}

resource "aws_autoscaling_group" "app" {
  name                 = "am-${var.am_number}${var.cluster_iteration}-${var.node_env}-asg"
  vpc_zone_identifier  = ["${var.vpc_subnets[0].id}"]
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  user_data            = "${data.template_file.cloud_config.rendered}"
  launch_configuration = "${aws_launch_configuration.app.name}"
}
