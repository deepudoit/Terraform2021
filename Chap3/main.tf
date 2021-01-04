provider "aws" {
  region = "us-east-1"
}

provider "random" {}

resource "random_pet" "name" {}

resource "aws_instance" "web" {
  ami = "ami-0be2609ba883822ec"
  instance_type = "t2.micro"
  user_data = file("init_script.sh")
  tags = {
    Name = random_pet.name.id
  }
}

resource "aws_security_group" "wb-sg" {
  name = "${random_pet.name.id}-sg"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "domain" {
  value = aws_instance.web.public_dns
}

output "application-url" {
  value = "${aws_instance.web.public_dns}/index.php"
}

