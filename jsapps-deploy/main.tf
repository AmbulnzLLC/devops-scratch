provider "aws" {
	region = "${var.aws_region}"
}

resource "aws_autoscaling_group" "app" {
  name                 = "am-${var.am_number}${var.cluster_iteration}-${var.node_env}-asg"
  vpc_zone_identifier  = ["${aws_subnet.main.*.id}"]
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.app.name}"
}
