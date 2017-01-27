provider "aws" {
    region = "us-west-2"
}

variable "server_name" {
  description = "A name for the build server"
  default = "build-server"
}

variable "key_name" {
  description = "The AWS-managed name of the key needed to SSH into this instance"
  default = "unsafe"
}

variable "ami_id" {
  default = "ami-517dc431"
}

variable "role_name" {
  description = "The IAM role to attach to the host"
  default = "devops-containerhost"
}

resource "aws_iam_instance_profile" "host" {
  roles = ["${var.role_name}"]
}

resource "aws_instance" "dopserver" {
    ami = "${var.ami_id}"
    instance_type = "m4.large"
    iam_instance_profile = "${aws_iam_instance_profile.host.name}"
    key_name = "${var.key_name}"
    tags {
        Name = "${var.server_name}"
    }
}

output "instance_id" {
  value = "${aws_instance.dopserver.id}"
}

output "instance_ip" {
  value = "${aws_instance.dopserver.public_ip}"
}
