output "instance_ip_addr" {
  value       = "Public IP: ${aws_instance.myinstance.public_ip}"
  description = "The public IP address of the main server instance."
}
