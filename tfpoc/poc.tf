provider "aws" {
	region = "us-west-2"	
}

resource "aws_instance" "tfexample" {
	ami = "ami-1e299d7e"
	instance_type = "t2.micro"
}
