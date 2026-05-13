output "instance_public_ip" {
  description = "The public IP address of the Minecraft server"
  value       = aws_instance.minecraft_server.public_ip
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.minecraft_repo.repository_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for world data"
  value       = aws_s3_bucket.minecraft_world_data.bucket
}