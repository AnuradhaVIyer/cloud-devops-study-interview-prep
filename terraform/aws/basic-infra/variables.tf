variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "env_prefix" {
  description = "The prefix for the environment"
  type        = string
  default     = "dev"
}

variable "project_prefix" {
  description = "The prefix for the project"
  type        = string
  default     = "devops-portfolio"
}