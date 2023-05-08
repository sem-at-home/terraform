provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0dda7e535b65b6469"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
