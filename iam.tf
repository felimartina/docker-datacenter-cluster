data "template_file" "ddc_instance_role_policy" {
  template = "${file("${path.module}/iam-policies/ec2-role-trust-policy.tpl")}"
}

data "template_file" "ec2_instance_policy" {
  template = "${file("${path.module}/iam-policies/ec2-instance-policy.tpl")}"

  vars = {
    S3_CONFIGURATIONS_BUCKET_NAME = "${aws_s3_bucket.configurations.id}"
    AWS_REGION                    = "${var.aws_region}"
  }
}

resource "aws_iam_role" "ddc_instance_role" {
  name               = "${var.service}-${var.service_instance}-ddc-instance-role"
  assume_role_policy = "${data.template_file.ddc_instance_role_policy.rendered}"
}

resource "aws_iam_role_policy" "ec2_instance_policy" {
  name   = "${var.service}-${var.service_instance}-ec2-instance-policy"
  policy = "${data.template_file.ec2_instance_policy.rendered}"
  role   = "${aws_iam_role.ddc_instance_role.id}"
}

resource "aws_iam_instance_profile" "ddc" {
  name = "${var.service}-${var.service_instance}-ddc-instance-profile"
  path = "/"
  role = "${aws_iam_role.ddc_instance_role.name}"
}
