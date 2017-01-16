variable "webserver_port" {
	description = "the port for busybox to listen on"
	default = 8080
}

provider "aws" {
	region = "us-west-2"	
}

resource "aws_launch_configuration" "tfexample" {
	ami = "ami-b7a114d7"
	instance_type = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.instance.id}"]

	user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.webserver_port}" &
              EOF

  	lifecycle {
  		create_before_destroy = true
  	}
}

resource "aws_security_group" "instance" {
  	name = "terraform-example-instance"

  	ingress {
    	from_port   = "${var.webserver_port}"
    	to_port     = "${var.webserver_port}"
    	protocol    = "tcp"
    	cidr_blocks = ["0.0.0.0/0"]
  	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.tfexample.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.webserver_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.webserver_port}/"
  }
}

output "elb_dns_name" {  value = "${aws_elb.example.dns_name}"}
