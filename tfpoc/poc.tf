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
	launch_configuration = "${aws_launch_configuration.example.id}"

  	min_size = 2
  	max_size = 10

  	tag {
    	key                 = "Name"
    	value               = "terraform-asg-example"
    	propagate_at_launch = true
  	}
}
