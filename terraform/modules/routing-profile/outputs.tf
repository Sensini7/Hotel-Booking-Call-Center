output "routing_profile_id" {
  description = "The identifier of the routing profile"
  value       = aws_connect_routing_profile.this.routing_profile_id
}

output "routing_profile_arn" {
  description = "The Amazon Resource Name (ARN) of the routing profile"
  value       = aws_connect_routing_profile.this.arn
}
