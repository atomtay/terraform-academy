resource "aws_iam_instance_profile" "backend_server" {
  name = "backend_server_iam_instance_profile"
  role = aws_iam_role.project.name
}

resource "aws_iam_role" "project" {
  name               = "project_role"
  assume_role_policy = <<EOF
{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {"Service": "ec2.amazonaws.com"},
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}

# data "aws_iam_policy_document" "assume_role" {
# }
