provider "aws" {
	region = "us-west-2"	
}

resource "aws_instance" "tfexample" {
	ami = "ami-1e299d7e"
	instance_type = "t2.micro"

	user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  	tags {
    	Name = "terraform-example"
  	}
}
