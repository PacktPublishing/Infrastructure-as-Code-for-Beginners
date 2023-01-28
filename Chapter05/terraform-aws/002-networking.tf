
# Create the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_address_space
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-vpc" }))
}

# Add the subnets to the VPC
resource "aws_subnet" "web01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 0)
  availability_zone = var.zones[0]
  tags              = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-web01-subnet" }))
}

resource "aws_subnet" "web02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 1)
  availability_zone = var.zones[1]
  tags              = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-web02-subnet" }))
}

resource "aws_subnet" "rds01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 2)
  availability_zone = var.zones[2]
  tags              = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-rds01-subnet" }))
}

resource "aws_subnet" "rds02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 3, 3)
  availability_zone = var.zones[3]
  tags              = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-rds02-subnet" }))
}


# Create the Internet Gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-igw" }))
}

# Create an Egress Route to the Internet Gateway
resource "aws_route_table" "vpc_igw_route" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-route" }))

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

}

resource "aws_route_table_association" "rta_subnet_public01" {
  subnet_id      = aws_subnet.web01.id
  route_table_id = aws_route_table.vpc_igw_route.id
}

resource "aws_route_table_association" "rta_subnet_public02" {
  subnet_id      = aws_subnet.web02.id
  route_table_id = aws_route_table.vpc_igw_route.id
}

# Create a Security Group for the VPC
resource "aws_security_group" "sg_vms" {
  name        = "${var.name}-${var.environment_type}-sg-web"
  description = "Allow various inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}sg-web" }))

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_efs" {
  name        = "${var.name}-${var.environment_type}-sg-efs"
  description = "Allow various inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-sg-efs" }))

  ingress {
    description     = "NFS"
    security_groups = ["${aws_security_group.sg_vms.id}"]
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_rds" {
  name        = "${var.name}-${var.environment_type}-sg-rds"
  description = "Allow various inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-sg-rds" }))

  ingress {
    description     = "NFS"
    security_groups = ["${aws_security_group.sg_vms.id}"]
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an application load balancer in aws and attach it to the web subnet
resource "aws_lb" "lb" {
  name               = "${var.name}-${var.environment_type}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_vms.id]
  subnets            = [aws_subnet.web01.id, aws_subnet.web02.id]

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-lb" }))
}

# Create a target group for the load balancer
resource "aws_lb_target_group" "front_end" {
  name     = "${var.name}-${var.environment_type}-front-end"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path = "/"
  }

  tags = merge(var.default_tags, tomap({ Name = "${var.name}-${var.environment_type}-front-end" }))
}

# Create a listener for the load balancer
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}