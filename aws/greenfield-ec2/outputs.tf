output "instance_ip_addr" {
  value       = aws_instance.myinstance.public_ip
  description = "The public IP address of the main server instance."
}
