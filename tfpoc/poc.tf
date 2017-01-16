provider "aws" {
	access_key = "AKIAIWFBGM36GXAJPW7Q"
	secret_key = "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"
	region = "us-west-2"	
}

resource "aws_instance" "tfexample" {
	ami = "ami-1e299d7e"
	instance_type = "t2.micro"
}
