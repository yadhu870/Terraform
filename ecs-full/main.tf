
resource "aws_vpc" "myvpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "sub1" {
  vpc_id                 = aws_vpc.myvpc.id
  cidr_block             = var.subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone      = "us-west-2a"
  tags = {
    Name = "sub1"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id                 = aws_vpc.myvpc.id
  cidr_block             = var.subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone      = "us-west-2b"
  tags = {
    Name = "sub2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "my-rt"
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "tf-sec" {
  name   = "tf-sec"
  vpc_id = aws_vpc.myvpc.id
ingress {
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ecs_cluster" "mycluster" {
  name = var.aws-clustername
}

resource "aws_ecs_task_definition" "tashd" {
  family                   = var.ecs-task-d
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = var.task_role
  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          }
      ]
    }
  ])
}
resource "aws_lb" "example" {
  name               = "yadhu-ecs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf-sec.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]
}

resource "aws_lb_target_group" "example" {
  name       = "yadhu-tg"
  port       = 8080
  protocol   = "HTTP"
  vpc_id     = aws_vpc.myvpc.id
  target_type = "ip"  # Change target type to ip
  health_check {
    path     = "/"
    interval = 30
  }
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_ecs_service" "example" {
  name            = var.ecs-service
  cluster         = aws_ecs_cluster.mycluster.id
  task_definition = aws_ecs_task_definition.tashd.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]
    security_groups = [aws_security_group.tf-sec.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "yadhutomcat"  # This should match the container name in the task definition
    container_port   = 8080
  }
  depends_on = [
    aws_lb_listener.example
  ]
}
output "lb_dns" {
  value = aws_lb.example.dns_name
}