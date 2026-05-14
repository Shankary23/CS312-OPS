variable "aws_region" {
  description = "The AWS region to deploy the infrastructure."
  type        = string
  default     = "us-east-1"
}

# Dont need it since we are doing it in the main.tf 
# variable "ami_id" {
#   description = "The Amazon Machine Image ID for the EC2 instance (e.g., Amazon Linux 2023)."
#   type        = string
#   # Note: You will need to find the specific AMI ID for your region in AWS Academy
# }

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.small" 
}