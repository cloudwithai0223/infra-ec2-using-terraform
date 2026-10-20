resource "aws_key_pair" "my_key" {
  key_name   = "terraform-key-ec2"
  public_key = file("aicloud.pub")
}

resource "aws_default_vpc" "default" {
}
resource "aws_security_group" "my-security-group" {
  name        = "automate-sg"
  description = "This will terraform generated sg"
  vpc_id      = aws_default_vpc.default.id


  #Inbound Rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "This is SSH por for all"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "This secure port"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "all access open outbound"
  }
  tags = {
    name = "autpmate-sg"
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  user_data = file("ecom-webpage.sh")
  instance_type = var.instance_type
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [
    aws_security_group.my-security-group.id
  ]
  root_block_device {
    volume_size = var.ec2_root_storage
    volume_type = "gp3"
  }
  tags = {
    Name = "learn-terraform"
  }
}
