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
