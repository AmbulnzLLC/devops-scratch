provider "aws" {
	access_key = "AKIAIWFBGM36GXAJPW7Q"
	secret_key = "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"
	region = "us-west-2"	
}

resource "aws_instance" "tfexample" {
	ami = "ami-0d729a60"
	instance_type = "t2.micro"
}
