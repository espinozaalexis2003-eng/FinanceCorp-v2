data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name               = "FinanceCorp-v2-EC2-SSM-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Project = "FinanceCorp-v2"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "FinanceCorp-v2-EC2-Profile"
  role = aws_iam_role.ec2_ssm.name
}


# Least-privilege policy for downloading application files
data "aws_iam_policy_document" "app_s3_read" {
  statement {
    sid = "ReadFinanceCorpApplication"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.application.arn}/application/*"
    ]
  }
}

resource "aws_iam_role_policy" "app_s3_read" {
  name   = "FinanceCorp-v2-App-S3-Read"
  role   = aws_iam_role.ec2_ssm.id
  policy = data.aws_iam_policy_document.app_s3_read.json
}
