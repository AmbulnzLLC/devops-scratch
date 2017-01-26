
provider "aws" {
    region = "us-west-2"
}

variable "buildserver_name" {
  description = "A name for the build server"
  default = "container-host"
}

variable "key_name" {
  description = "The AWS-managed name of the key needed to SSH into this instance"
  default = "unsafe"
}

variable "ami_id" {
  default = "ami-10823b70"
}

resource "aws_instance" "dopserver" {
    ami = "${var.ami_id}"
    instance_type = "m4.large"
    key_name = "${var.key_name}"
    tags {
        Name = "${var.buildserver_name}"
    }
}

output "instance_id" {
  value = "${aws_instance.dopserver.id}"
}
