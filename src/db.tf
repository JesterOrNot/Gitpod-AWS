# Create a database server
resource "aws_db_instance" "gitpod" {
  engine               = "mysql"
  engine_version       = "5.7.21"
  instance_class       = "db.t2.micro"
  name                 = var.database.name
  username             = var.database.user-name
  password             = var.database.password
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.gitpod.id
}

provider "mysql" {
  endpoint = aws_db_instance.gitpod.endpoint
  username = aws_db_instance.gitpod.username
  password = aws_db_instance.gitpod.password
}

resource "aws_db_subnet_group" "gitpod" {
  name       = "main"
  subnet_ids = aws_subnet.gitpod[*].id

  tags = {
    Name = "My DB subnet group"
  }
}
