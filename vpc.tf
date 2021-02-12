
/* 1) create a vpc
     2)create a gateway and attach to vpc
     3)create a subnet for public
     4)create a subnet for private
     5)create a route table for pub subnet
     6)create a route table for priv subnet
     7)associate route table to pub subnet and create routes
     8)associate another route table to priv subnet
     9)create a security group
     10)create a vm in pub subnet 
  
*/
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/24"
tags = {
    Name = "DevOpsClass"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "7amist"
  }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/25"

  tags = {
    Name = "pub7amist"
  }
}
resource "aws_subnet" "privsub" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.128/25"

  tags = {
    Name = "priv7amist"
  }
}

resource "aws_route_table" "r1" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

 
  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "r2" {
  vpc_id = "${aws_vpc.main.id}"

 
  tags = {
    Name = "main"
  }
}



resource "aws_route_table_association" "a1" {
  subnet_id      = "${aws_subnet.pubsub.id}"
  route_table_id = "${aws_route_table.r1.id}"
}
 
resource "aws_route_table_association" "a2" {
  subnet_id = "${aws_subnet.privsub.id}"
  route_table_id ="${aws_route_table.r2.id}"

 
}

resource "aws_security_group" "sg1" {
  vpc_id ="${aws_vpc.main.id}"
  description ="tfsg"
  name="tfsg"
  ingress   {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "deployer" {
  key_name="mykey"
  public_key = "${file("./mykey.pub")}"
}
resource "aws_instance" "i1" {
  ami="ami-ami-e32930428bf1abbff"
  instance_type="t2.micro"
  key_name="${aws_key_pair.deployer.key_name}"
  subnet_id ="${aws_subnet.pubsub.id}"
  vpc_security_group_ids=["${aws_security_group.sg1.id}"]
  user_data="${file("./web.sh")}"
  associate_public_ip_address=true
}
