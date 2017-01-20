output "lb_url" {
	value = "${aws_alb.main.dns_name}"
}

output "lb_zone_id" {
	value = "${aws_alb.main.zone_id}"
}
