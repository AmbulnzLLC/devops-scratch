provider "aws" {
	region = "${var.aws_region}"
}

resource "aws_launch_configuration" "app" {
	security_groups = ["${var.cluster_security_group_id}"]
	key_name = "${var.keypair_name}"
}

resource "aws_autoscaling_group" "app" {
  name                 = "am-${var.am_number}${var.cluster_iteration}-${var.node_env}-asg"
  vpc_zone_identifier  = ["${aws_subnet.main.*.id}"]
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.app.name}"
}
