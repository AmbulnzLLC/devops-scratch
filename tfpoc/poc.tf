variable "webserver_port" {
	description: "the port for busybox to listen on"
	default: 8080
}

provider "aws" {
	region = "us-west-2"	
}

resource "aws_instance" "tfexample" {
	ami = "ami-b7a114d7"
	instance_type = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.instance.id}"]

	user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.webserver_port}" &
              EOF

  	tags {
    	Name = "terraform-example"
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
}

output "public_ip" {
	value = "${aws_instance.tfexample.public_ip}"
}
