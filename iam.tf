resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "secrets_manager_read_policy" {
  name        = "secrets_manager_read_policy"
  description = "policy to allow the ec2 instance to read from the secrets manager"

  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow",
        Action : ["secretsmanager:*", ]
        Resource : "arn:aws:secretsmanager:eu-central-1:626205521754:secret:database-cred-??????"
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2-policy-attach" {
  name       = "ec2-policy-test-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
}

resource "aws_iam_instance_profile" "wordpress_instance_profile" {
  role = aws_iam_role.ec2_role.name
}
