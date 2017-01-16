provider "aws" {
	access_key = "AKIAIWFBGM36GXAJPW7Q"
	secret_key = "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"
	region = "us-west-2"	
}

resource "aws_instance" "tfexample" {
	ami = "ami-408c7f28"
	instance_type = "t1.micro"
}
