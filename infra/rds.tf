resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = aws_subnet.main.*.id
}

resource "random_password" "postgres_admin_password" {
  length  = 32
  special = false
}

resource "random_password" "postgres_app_password" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "default" {
  subnet_ids = [for subnet in aws_subnet.main : subnet.id]
}

resource "aws_db_instance" "postgres" {
  #checkov:skip=CKV_AWS_17:Create public IP because we don't have access to private GH Actions runners
  apply_immediately         = true
  db_name                   = "todo"
  engine                    = "postgres"
  engine_version            = "13.4"
  instance_class            = "db.t3.micro"
  allocated_storage         = 5
  password                  = random_password.postgres_admin_password.result
  username                  = "myadmin"
  port                      = 5432
  publicly_accessible       = true
  multi_az                  = true
  db_subnet_group_name      = aws_db_subnet_group.default.name
  vpc_security_group_ids    = [aws_security_group.backend_server.id]
  final_snapshot_identifier = "last-snapshot"

  lifecycle {
    ignore_changes = [
      snapshot_identifier,
      latest_restorable_time,
    ]
  }
}

