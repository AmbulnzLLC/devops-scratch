variable "buildserver_name" {
  description = "A name for the build server"
  default = "devops-buildserver"
}

variable "key_name" {
  description = "The AWS-managed name of the key needed to SSH into this instance"
  default = "unsafe"
}

provider "aws" {
    region = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "dopserver" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "m4.large"
    key_name = "${var.key_name}"
    tags {
        Name = "${var.buildserver_name}"
    }
}

output "instance_id" {
  value = "${aws_instance.dopserver.id}"
}
