data "aws_ami" "aws_ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "ubuntu_instance" {
  ami                         = data.aws_ami.aws_ubuntu.id
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.main_subnet_a.id
  key_name                    = "${var.unique_prefix}_keypair"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.ubuntu_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ubuntu_profile.name
  root_block_device{
      volume_size = 100
      volume_type = "gp2"
    }

  user_data = var.log4j_user_data

  tags = {
    Name   = "${var.unique_prefix}-ubuntu-frontend-app"
  }
}