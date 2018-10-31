data "aws_acm_certificate" "domain" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]
}

resource "aws_route53_record" "ucp" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.ucp_subdomain}.${var.domain}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.ucp_lb.dns_name}"
    zone_id                = "${aws_lb.ucp_lb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dtr" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.dtr_subdomain}.${var.domain}"
  type    = "A"

  alias = {
    name                   = "${aws_lb.dtr_lb.dns_name}"
    zone_id                = "${aws_lb.dtr_lb.zone_id}"
    evaluate_target_health = true
  }
}
