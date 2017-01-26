
provider "aws" {
    region = "us-west-2"
}

variable "server_name" {
  description = "A name for the build server"
  default = "container-host"
}

variable "key_name" {
  description = "The AWS-managed name of the key needed to SSH into this instance"
  default = "unsafe"
}

variable "ami_id" {
  default = "ami-d37bc2b3"
}

resource "aws_instance" "dopserver" {
    ami = "${var.ami_id}"
    instance_type = "m4.large"
    key_name = "${var.key_name}"
    tags {
        Name = "${var.server_name}"
    }
}

output "instance_id" {
  value = "${aws_instance.dopserver.id}"
}

output "instance_ip" {
  value = "${aws_instance.dopserver.public_ipy}"
}
