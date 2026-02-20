variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 24.04 x86_64 instances in the selected region"
  type        = string
  default     = "" # Set in terraform.tfvars (e.g. Ubuntu 24.04 AMI for your region)
}

variable "service1_repo_name" {
  description = "ECR repository name for service1"
  type        = string
  default     = "service1"
}

variable "service2_repo_name" {
  description = "ECR repository name for service2"
  type        = string
  default     = "service2"
}

variable "instance_type" {
  description = "EC2 instance type for ASG instances"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "microservices-key"
}

variable "instance_profile_name" {
  description = "IAM instance profile name attached to ASG instances"
  type        = string
  default     = "ec2-ecr-pull-role"
}

variable "ec2_security_group_id" {
  description = "Security group ID for EC2 instances (e.g., ec2-sg)"
  type        = string
  default     = "" # Set in terraform.tfvars (your EC2 security group ID, e.g. ec2-sg)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ASG instances"
  type        = list(string)
  default = [] # Set in terraform.tfvars (your public subnet IDs for ASG)
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
  default     = "microservices-asg"
}

variable "launch_template_name" {
  description = "Launch Template name"
  type        = string
  default     = "microservices-lt"
}

variable "target_group_service1_name" {
  description = "Existing ALB target group name for service1"
  type        = string
  default     = "tg-service1"
}

variable "target_group_service2_name" {
  description = "Existing ALB target group name for service2"
  type        = string
  default     = "tg-service2"
}

variable "cpu_scale_out_threshold" {
  description = "CPU percentage threshold for scale-out"
  type        = number
  default     = 40
}

variable "cpu_scale_out_evaluation_periods" {
  description = "Number of 60-second periods for alarm evaluation"
  type        = number
  default     = 5
}

variable "cpu_scale_out_cooldown_seconds" {
  description = "Cooldown in seconds after scale-out"
  type        = number
  default     = 300
}
