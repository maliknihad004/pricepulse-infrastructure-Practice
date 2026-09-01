output "vpc_id" {
  description = "ID of the PricePulse VPC"
  value       = aws_vpc.pricepulse.id
}

output "ec2_instance_id" {
  description = "ID of the PricePulse EC2 instance"
  value       = aws_instance.pricepulse.id
}

output "ec2_public_ip" {
  description = "Public IP address of the PricePulse EC2 instance"
  value       = aws_instance.pricepulse.public_ip
}