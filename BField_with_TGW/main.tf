provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create the vpc for brownfield1
resource "aws_vpc" "brownfield1_vpc" {
  cidr_block = var.cidr_block_br1

  tags = {
    Name = "brownfield1-vpc"
  }
}



# Create the vpc for brownfield2
resource "aws_vpc" "brownfield2_vpc" {
  cidr_block = var.cidr_block_br2

  tags = {
    Name = "brownfield2-vpc"
  }
}



# Create the subnet for the brownfield1_vpc
resource "aws_subnet" "brownfield1-subnet" {
  vpc_id            = aws_vpc.brownfield1_vpc.id
  availability_zone = var.availability_zone1
  cidr_block        = var.subnet_br1

  tags = {
    Name = "brownfield1-subnet"
  }
}

# Create the subnet for the brownfield2_vpc
resource "aws_subnet" "brownfield2-subnet" {
  vpc_id            = aws_vpc.brownfield2_vpc.id
  availability_zone = var.availability_zone1
  cidr_block        = var.subnet_br2

  tags = {
    Name = "brownfield2-subnet"
  }
}

# Create the IGW for Brownfield1
resource "aws_internet_gateway" "igw-brownfield1" {
  vpc_id = aws_vpc.brownfield1_vpc.id

  tags = {
    Name = "brownfield1-igw"
  }
}

# Create the IGW for Brownfield2
resource "aws_internet_gateway" "igw-brownfield2" {
  vpc_id = aws_vpc.brownfield2_vpc.id

  tags = {
    Name = "brownfield2-igw"
  }
}


# Tag the default route-table created for brownfield1

resource "aws_default_route_table" "br1-rt" {
  default_route_table_id = aws_vpc.brownfield1_vpc.default_route_table_id

  tags = {
    Name = "brownfield1-RT-Main"
  }
}


# Tag the default route-table created for brownfield2

resource "aws_default_route_table" "br2-rt" {
  default_route_table_id = aws_vpc.brownfield2_vpc.default_route_table_id

  tags = {
    Name = "brownfield2-RT-Main"
  }
}


# Create Custom route table for brownfield1

resource "aws_route_table" "br1-rt" {
  vpc_id = aws_vpc.brownfield1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-brownfield1.id
  }

  tags = {
    Name = "brownfield1-RT"
  }
}

# Create Custom route table for brownfield2

resource "aws_route_table" "br2-rt" {
  vpc_id = aws_vpc.brownfield2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-brownfield2.id
  }

  tags = {
    Name = "brownfield2-RT"
  }
}

# Associate Custom Route table for brownfield1 with brownfield1-subnet

resource "aws_route_table_association" "br1-rt" {
  subnet_id      = aws_subnet.brownfield1-subnet.id
  route_table_id = aws_route_table.br1-rt.id
}

# Associate Custom Route table for brownfield1 with brownfield1-subnet

resource "aws_route_table_association" "br2-rt" {
  subnet_id      = aws_subnet.brownfield2-subnet.id
  route_table_id = aws_route_table.br2-rt.id
}

/*   Commenting out the default route table route associations

# Associate the route table created for brownfield1, associate with briwnfield1-IGW
resource "aws_route" "br1-default_to_igw" {
  route_table_id         = aws_vpc.brownfield1_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw-brownfield1.id
}


# Associate the route table created for brownfield2, associate with briwnfield1-IGW
resource "aws_route" "br2-default_to_igw" {
  route_table_id         = aws_vpc.brownfield2_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw-brownfield2.id
}

*/




# Get ID for Amazon EC2 (basic)

data "aws_ami" "std_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# create the security group for brownfield1
resource "aws_security_group" "br1-allow_all" {
  name        = "br-1-allow_all-sgroup"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.brownfield1_vpc.id

  ingress {
    description = "All Traffic Inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All Traffic Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "br1_all-in_out-SG"
  }

}

# create the security group for brownfield2
resource "aws_security_group" "br2-allow_all" {
  name        = "br-1-allow_all-sgroup"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.brownfield2_vpc.id

  ingress {
    description = "All Traffic Inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All Traffic Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "br2_all-in_out-SG"
  }

}

# Create a Transit Gateway so EC2s of the 2 brownfields can talk to each other through AWS directly
resource "aws_ec2_transit_gateway" "brownfieldTGW" {
  description                     = "Transit Gateway for the 2 Brownfields to talk to each other"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "br1-to-br2-TGW"
  }
}

# Create Transit Gateway Attachment to brownfield1 VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Attachment-BR1_VPC" {
  subnet_ids         = [aws_subnet.brownfield1-subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.brownfieldTGW.id
  vpc_id             = aws_vpc.brownfield1_vpc.id

  tags = {
    Name = "TGW-Attach-BR1VPC"
  }

}

# Create Transit Gateway Attachment to brownfield2 VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "TGW-Attachment-BR2_VPC" {
  subnet_ids         = [aws_subnet.brownfield2-subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.brownfieldTGW.id
  vpc_id             = aws_vpc.brownfield2_vpc.id

  tags = {
    Name = "TGW-Attach-BR2VPC"
  }

}

/* Commenting out the Transit Gateway Route on the default route tables

# Associate the route table created for brownfield1, associate with briwnfield-TGW
resource "aws_route" "br1-To-BR2_viaTGW" {
  route_table_id         = aws_vpc.brownfield1_vpc.default_route_table_id
  destination_cidr_block = aws_vpc.brownfield2_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.brownfieldTGW.id
}


# Associate the route table created for brownfield2, associate with brownfield-TGW
resource "aws_route" "br2-To-BR1_viaTGW" {
  route_table_id         = aws_vpc.brownfield2_vpc.default_route_table_id
  destination_cidr_block = aws_vpc.brownfield1_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.brownfieldTGW.id
}

*/


# Associate the Transit Gateway Route on the custom route table
# Transit Gateway Route for brownfield1, associate with TGW
resource "aws_route" "br1-To-BR2_viaTGW" {
  route_table_id         = aws_route_table.br1-rt.id
  destination_cidr_block = aws_vpc.brownfield2_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.brownfieldTGW.id
}


# Transit Gateway Route for brownfield2, associate with TGW
resource "aws_route" "br2-To-BR1_viaTGW" {
  route_table_id         = aws_route_table.br1-rt.id
  destination_cidr_block = aws_vpc.brownfield2_vpc.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.brownfieldTGW.id
}

# Create keypair for ssh
resource "aws_key_pair" "loginkey1" {
  key_name = try("phy-login-key-br") #  using function try here.  If key is already present don't mess with it
  # use the below method instead if desired 
  #public_key = file("${path.module}/.certs/id_rsa.pub")  # #  path.module is in relation to the current directory, in case you want to put your id_rsa.pub in ./.certs folder
  public_key = file("~/.ssh/id_rsa.pub")
}


# Create ec2 for brownfield1

resource "aws_instance" "br1-ec2" {
  ami                         = data.aws_ami.std_ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.brownfield1-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.br1-allow_all.id]
  key_name                    = aws_key_pair.loginkey1.key_name
  count                       = var.num_inst
  tags = {
    Name = "ec2-${count.index}-br1" # first instance will be ec2-0, then ec2-1 etc, etc
  }
}



# install httpd on ec2s for brownfield1
resource "null_resource" "update-br1" {
  depends_on = [aws_instance.br1-ec2]
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 30" # buy a little time to make sure ec2 is reachable
  }
}


# add route to br1 vpc







# install httpd on all the EC2 instances.  We are using count.index to make sure all EC2s are configured
resource "null_resource" "apache2-br1" {
  depends_on = [null_resource.update-br1]
  count      = var.num_inst
  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd  -y",
      "echo Hello world from $(hostname), private ip = $(hostname -i) > index.html",
      "sudo mv index.html /var/www/html/index.html",
      "sudo service httpd start",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user" # this is the inbuilt ec2 user name for the used ami
      private_key = file("~/.ssh/id_rsa")
      host        = aws_instance.br1-ec2[count.index].public_ip
    }
  }
}
#  Outputs:
# Show Public IPs
output "publicIP-br1-ec2s" {

  value = {
    for instance in aws_instance.br1-ec2 :
    instance.id => instance.public_ip
  }
}

variable "info-br1-ec2" {
  default = "ssh with:  ec2-user@public_ip ; curl public_ip  will show you the private ip of this ec2"
}

output "showinfo-br1" {
  value = {
    "username" = var.info-br1-ec2
  }
}



# Create ec2 for brownfield2

resource "aws_instance" "br2-ec2" {
  ami                         = data.aws_ami.std_ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.brownfield2-subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.br2-allow_all.id]
  key_name                    = aws_key_pair.loginkey1.key_name
  count                       = var.num_inst
  tags = {
    Name = "ec2-${count.index}-br2" # first instance will be ec2-0, then ec2-1 etc, etc
  }
}



# install httpd on ec2s for brownfield2
resource "null_resource" "update-br2" {
  depends_on = [aws_instance.br2-ec2]
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "sleep 30" # buy a little time to make sure ec2 is reachable
  }
}




# install httpd on all the br2-EC2 instances.  We are using count.index to make sure all EC2s are configured
resource "null_resource" "apache2-br2" {
  depends_on = [null_resource.update-br2]
  count      = var.num_inst
  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd  -y",
      "echo Hello world from $(hostname), private ip = $(hostname -i) > index.html",
      "sudo mv index.html /var/www/html/index.html",
      "sudo service httpd start",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user" # this is the inbuilt ec2 user name for the used ami
      private_key = file("~/.ssh/id_rsa")
      host        = aws_instance.br2-ec2[count.index].public_ip
    }
  }
}
#  Outputs:
# Show Public IPs
output "publicIP-br2-ec2s" {

  value = {
    for instance in aws_instance.br2-ec2 :
    instance.id => instance.public_ip
  }
}

variable "info-br2-ec2" {
  default = "ssh with:  ec2-user@public_ip ; curl public_ip  will show you the private ip of this ec2"
}

output "showinfo-br2" {
  value = {
    "username" = var.info-br2-ec2
  }
}
