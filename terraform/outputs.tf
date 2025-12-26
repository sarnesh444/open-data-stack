output "public_ip" {
  value       = aws_instance.trino_server.public_ip
  description = "Public IP of the Trino server"
}

output "trino_url" {
  value       = "http://${aws_instance.trino_server.public_ip}:8080"
  description = "URL for Trino UI"
}

output "superset_url" {
  value       = "http://${aws_instance.trino_server.public_ip}:8088"
  description = "URL for Superset"
}
