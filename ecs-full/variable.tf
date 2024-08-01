provider "aws" {
  region = "us-west-2"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr" {
  description = "CIDR block for the first subnet"
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr" {
  description = "CIDR block for the second subnet"
  default     = "10.0.2.0/24"
}

variable "aws-clustername" {
  description = "clustername"
  default = "yadhu-aws-tools"
}
variable "ecs-task-d" {
  description = "task defenition name"
  default = "my-ecs-task"
}
variable "container_name" {
  description = "container name"
  default = "yadhutomcat"
}
variable "container_image" {
  description = "container image"
  default = "public.ecr.aws/k2b2d0w8/yadhutomcat"
}
variable "ecs-service" {
  description = "ecs service name"
  default = "yadhu-service"
}
variable "task_role" {
  description = "task execution role"
  default = "arn:aws:iam::274822064527:role/ecsTaskExecutionRole"
}