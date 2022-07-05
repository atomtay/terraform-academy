resource "aws_security_group" "backend_server" {
  #checkov:skip=CKV_AWS_24:Enable ssh access from all sources since we don't have access to private GH Actions runners
  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name}"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "allow_all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = concat(
      aws_subnet.main.*.cidr_block,
      aws_subnet.public.*.cidr_block,
    )
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "postgres-self"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = aws_subnet.main.*.cidr_block
  }
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
resource "aws_instance" "backend_server" {
  #checkov:skip=CKV_AWS_88:Allow public IP for ssh access deploy since we don't have access to private GH Actions runners
  count = length(data.aws_availability_zones.available.names)

  depends_on = [aws_route_table.main]

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.nano"
  availability_zone           = data.aws_availability_zones.available.names[count.index]
  iam_instance_profile        = aws_iam_instance_profile.backend_server.name
  vpc_security_group_ids      = [aws_security_group.backend_server.id]
  subnet_id                   = aws_subnet.main[count.index].id
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh_key.key_name

  tags = var.aws_tags
}

