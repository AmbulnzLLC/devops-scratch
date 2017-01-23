variable "aws_region" { default = "us-west-2" }

variable "webrequester_port" {
	description = "the port for webrequester to listen on"
	default = 5600
}

variable "relay_port" {
	description = "the port for relay server to listen on"
	default = 5100
}

variable "api_port" {
	description = "the port for API server to listen on"
	default = 5000
}

variable "node_env" {
	description = "the node build environment"
	default = "sandbox"
}

variable "am_number" {
	description = "the JIRA task being built for"
	default = "0000"
}

variable "cluster_iteration" {
	description = "the version indicator of this build"
	default = "a"
}

variable "vpc_id" {
	description = "the id of the VPC to build on"
	default = "vpc-087ecb6f"
}

variable "vpc_subnets" {
	description = "a list of subnets to use for the cluster assets"
	type = "list"
	default = ["subnet-89a04cc0", "subnet-25a16b42"]
}

variable "vpc_azs" {
	description = "a list of availability zones for the VPC"
	type        = "list"
	default.    = ["us-west-2a", "us-west-2b"]
}

variable "cluster_size" {
	default = 1
}

variable "container_host_instance_type" {
	default = "m4.large"
}

variable "keypair_name" {
	default = "devops-containers"
}

variable "cluster_security_group_id" {
	default = "sg-f3b8718b"
}

variable "task_url" {
	description = "the source of the task containers"
	default = "ecs-compose-JSApps:latest"
}

variable "https_certificate_arn" {
	default = "arn:aws:acm:us-west-2:431240526133:certificate/cb30cdc3-b0e5-4b10-b7cf-3afef12c06e7"
}
