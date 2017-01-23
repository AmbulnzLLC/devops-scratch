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

# IAM Artifacts

resource "aws_iam_role" "ecs_service" {
  name = "jsapps_ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service" {
  name = "jsapps_ecs_role_policy"
  role = "${aws_iam_role.ecs_service.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
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

data "template_file" "instance_profile" {
  template = "${file("${path.module}/instance-profile-policy.json")}"
}

resource "aws_iam_role_policy" "instance" {
  name   = "TfEcsExampleInstanceRole"
  role   = "${aws_iam_role.app_instance.name}"
  policy = "${data.template_file.instance_profile.rendered}"
}

# Add https target groups
resource "aws_alb_target_group" "https_default" {
  name     = "https-default-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_target_group" "https_api" {
  name     = "https-api-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_target_group" "https_relay" {
  name     = "https-relay-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_target_group" "http_default" {
  name     = "http-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

# Add load balancer
resource "aws_alb" "main" {
  name            = "af-${var.am_number}${var.cluster_iteration}-alb"
  subnets         = ["${var.vpc_subnets}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]
}

# Add HTTPS listener
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.https_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.https_default.id}"
    type             = "forward"
  }
}

# Add HTTP listener
resource "aws_alb_listener" "http_to_redirect" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.http_default.id}"
    type             = "forward"
  }
}

# Add listener rules for api/relay"
resource "aws_alb_listener_rule" "api" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority = 100

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.https_api.arn}"
  }

  condition {
    field = "path-pattern"
    values = ["/api/*"]
  }
}

resource "aws_alb_listener_rule" "relay" {
  listener_arn = "${aws_alb_listener.front_end.arn}"
  priority = 200

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.https_relay.arn}"
  }

  condition {
    field = "path-pattern"
    values = ["/socket.io/*"]
  }
}

# Add task
data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definition.json")}"

  vars {
    image_url            = "${var.task_url}"
    wr_container_name    = "webrequester"
    wr_port_num          = "${var.webrequester_port}"
    api_container_name   = "restserver"
    api_port_num         = "${var.api_port}"
    relay_container_name = "relay"
    relay_port_num       = "${var.relay_port}"
  }
}

resource "aws_ecs_task_definition" "jsapps" {
  family                = "jsapps_taskdef"
  container_definitions = "${data.template_file.task_definition.rendered}"

  placement_constraints {
    type        = "memberOf"
    expression  = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

# Add services
resource "aws_ecs_service" "webrequester" {
  name            = "jsapps-svc-wr"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${var.task_arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.https_default.id}"
    container_name   = "webrequester"
    container_port   = "${var.webrequester_port}"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end",
  ]
}

resource "aws_ecs_service" "restserver" {
  name            = "jsapps-svc-api"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.jsapps.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.https_api.id}"
    container_name   = "restserver"
    container_port   = "${var.api_port}"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end",
  ]
}

resource "aws_ecs_service" "relay" {
  name            = "jsapps-svc-relay"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.jsapps.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.https_relay.id}"
    container_name   = "relay"
    container_port   = "${var.relay_port}"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end",
  ]
}

# Add target group attachments
