
# >>>>>>>>>>>>>>>>>>>Provider Block>>>>>>>>>>>>>>>>>>
# Configure the AWS Provider
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            
        }
    }
}

provider "aws" {
    
    region = "ap-southeast-1"
}    

# >>>>>>>>>>>>>>>>>>>Resources block>>>>>>>>>>>>>>>>>
# to create security group
resource "aws_security_group" "web_sg" {
  name = "alb-lab-web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
# write a code to create a pair of EC2 instances as EC1 & EC2
resource "aws_instance" "web1" {
  ami           = "ami-0fa377108253bf620"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx

echo "<h1>Server 1</h1>" > /var/www/html/index.html

systemctl enable nginx
systemctl start nginx
EOF

  tags = {
    Name = "Web-Server-1"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-0fa377108253bf620"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y nginx

echo "<h1>Server 2</h1>" > /var/www/html/index.html

systemctl enable nginx
systemctl start nginx
EOF

  tags = {
    Name = "Web-Server-2"
  }
}

# to create SG a load balancer
resource "aws_security_group" "alb_sg" {
  name = "alb-lab-alb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
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

# to create VPC default state
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# to create a target group
resource "aws_lb_target_group" "web_tg" {
  name     = "alb-lab-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# to create a listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# to create two servers
resource "aws_lb_target_group_attachment" "web1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# to create application a load balancer
resource "aws_lb" "web_alb" {
  name               = "alb-lab"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = data.aws_subnets.default.ids
}


# to create the output the ALB dns name
output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}
