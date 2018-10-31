data "template_file" "docker" {
  template = "${file("${path.module}/templates/docker.sh.tpl")}"

  vars {
    DOCKER_EE_URL     = "${var.docker_ee_url}"
    DOCKER_EE_VERSION = "${var.docker_ee_version}"
  }
}

data "template_file" "node-manager" {
  template = "${file("${path.module}/templates/nodes/manager.sh.tpl")}"

  vars {
    DOCKER_INSTALL                = "${data.template_file.docker.rendered}"
    DOCKER_UCP_VERSION            = "${var.docker_ucp_version}"
    DOCKER_UCP_USERNAME           = "${var.ucp_username}"
    DOCKER_UCP_PASSWORD           = "${var.ucp_password}"
    DOCKER_DTR_VERSION            = "${var.docker_dtr_version}"
    ELB_MANAGER_NODES             = "${aws_lb.ucp_lb.dns_name}"
    UCP_PUBLIC_ENDPOINT           = "${var.ucp_subdomain}.${var.domain}"
    UCP_PORT                      = "${var.ucp_https_port}"
    S3_CONFIGURATIONS_BUCKET_NAME = "${aws_s3_bucket.configurations.id}"
    MASTER_NODE_EIP_ID            = "${aws_eip.master.id}"
    MASTER_NODE_IP                = "${aws_eip.master.public_ip}"
    REGION                        = "${var.aws_region}"
  }
}

data "template_file" "node-dtr" {
  template = "${file("${path.module}/templates/nodes/dtr.sh.tpl")}"

  vars {
    DOCKER_INSTALL                = "${data.template_file.docker.rendered}"
    DOCKER_UCP_USERNAME           = "${var.ucp_username}"
    DOCKER_UCP_PASSWORD           = "${var.ucp_password}"
    DOCKER_DTR_VERSION            = "${var.docker_dtr_version}"
    DTR_HTTP_PORT                 = "${var.dtr_http_port}"
    DTR_HTTPS_PORT                = "${var.dtr_https_port}"
    DTR_REPLICA_ID                = "${random_id.dtr_replica_id.hex}"
    DTR_PUBLIC_ENDPOINT           = "${var.dtr_subdomain}.${var.domain}"
    UCP_PUBLIC_ENDPOINT           = "${var.ucp_subdomain}.${var.domain}"
    S3_CONFIGURATIONS_BUCKET_NAME = "${aws_s3_bucket.configurations.id}"
    MASTER_NODE_IP                = "${aws_eip.master.public_ip}"
  }
}

data "template_file" "node-worker" {
  template = "${file("${path.module}/templates/nodes/worker.sh.tpl")}"

  vars {
    DOCKER_INSTALL                = "${data.template_file.docker.rendered}"
    S3_CONFIGURATIONS_BUCKET_NAME = "${aws_s3_bucket.configurations.id}"
    MASTER_NODE_IP                = "${aws_eip.master.public_ip}"
  }
}
