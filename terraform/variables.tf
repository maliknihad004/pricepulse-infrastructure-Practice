variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "ssh_public_key" {
  description = "SSH public key used to access the PricePulse EC2 instance"
  type        = string
}