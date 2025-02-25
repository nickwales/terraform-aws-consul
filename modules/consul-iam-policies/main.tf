# ---------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH AN IAM POLICY THAT ALLOWS THE CONSUL NODES TO AUTOMATICALLY DISCOVER EACH OTHER AND FORM A CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "auto_discover_cluster" {
  count  = var.enabled ? 1 : 0
  name   = "auto-discover-cluster"
  role   = var.iam_role_id
  policy = data.aws_iam_policy_document.auto_discover_cluster.json
}

data "aws_iam_policy_document" "auto_discover_cluster" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]

    resources = ["*"]
  }
}

// resource "aws_iam_role" "consul" {
//   count              = var.enabled ? 1 : 0
//   name_prefix        = var.cluster_name
//   assume_role_policy = data.aws_iam_policy_document.instance_role.json
// }

// data "aws_iam_policy" "ReadOnlyAccess" {
//   arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
// }

// data "aws_iam_policy" "SSMManagedInstance" {
//   arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
// }


resource "aws_iam_role_policy_attachment" "read-only-attach" {
#  role       = "${aws_iam_role.consul.0.name}"
  role       = var.iam_role_id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-attach" {
  #role       = "${aws_iam_role.consul.0.name}"
  role       = var.iam_role_id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}