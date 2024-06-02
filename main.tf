provider "aws" {
  region = "us-east-1"
}

//Create a VPC
resource "aws_vpc" "main-project-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main-Project-VPC"
  }
}

//Create Internet Gateway
resource "aws_internet_gateway" "main-project-gateway" {
  vpc_id = aws_vpc.main-project-vpc.id
  tags = {
    Name = "Main-Project-Gateway"
  }
}

//Create Custom Route Table
resource "aws_route_table" "main-project-route-table" {
  vpc_id = aws_vpc.main-project-vpc.id

  route {
    //Points all traffic to the default route
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-project-gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.main-project-gateway.id
  }

  tags = {
    Name = "Main-Project-Gateway"
  }
}

//Create Subnet
resource "aws_subnet" "main-project-subnet-1" {
  vpc_id     = aws_vpc.main-project-vpc.id
  cidr_block = "10.0.1.0/24"
  //Sets availability Zones
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main-Project-Subnet-1"
  }
}

//Associate Subnet with route table
resource "aws_route_table_association" "main-project-sub-route" {
  subnet_id      = aws_subnet.main-project-subnet-1.id
  route_table_id = aws_route_table.main-project-route-table.id
}

//Create Security group to allow port 22, 80, 443
resource "aws_security_group" "main-project-allow-web-traffic" {
  name        = "allow_web_traffic"
  description = "Allow web Inbound traffic"
  vpc_id      = aws_vpc.main-project-vpc.id

  tags = {
    Name = "Main-Project-AllowWeb"
  }

  ingress {
    from_port = 443
    to_port = 443
    description = "HTTPS"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    description = "HTTP"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    description = "SSH"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    //Any protocol will be allowed
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Create a network interface with an ip in the subnet previously created
# resource "aws_network_interface" "main-project-network-interface" {
#   subnet_id       = aws_subnet.main-project-subnet-1.id
#   private_ips     = ["10.0.1.50"]
#   security_groups = [aws_security_group.main-project-allow-web-traffic.id]
# }

//Assign an elastic IP to the network interface created above
# resource "aws_eip" "main-project-elastic-ip" {
#   network_interface = aws_network_interface.main-project-network-interface.id
#   domain   = "vpc"
#   associate_with_private_ip = "10.0.1.50"
#   depends_on = [aws_internet_gateway.main-project-gateway]
# }

# output "server_public_ip" {
#   value = aws_eip.main-project-elastic-ip.public_ip
# }

//Create ubuntu server and install/enable apache 2
resource "aws_instance" "main-project-instance" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  //Make sure your Instance and subnet are in the same.
  //Hard code the availability zone in both the subnet and instance.
  availability_zone = "us-east-1a"
  key_name = "terraform-main-keypair"
  associate_public_ip_address = true
  #   network_interface {
  #     device_index         = 0
  #     network_interface_id = aws_network_interface.main-project-network-interface.id
  #   }
  user_data = <<-EOF
                   #!/bin/bash
                   sudo apt update -y
                   sudo apt install apache2 -y
                   sudo systemctl start apache2
                   sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                   EOF
  tags = {
    Name = "Main-Project-Instance"
  }
}