output "hours_of_operation_id" {
  description = "The identifier of the hours of operation"
  value       = module.hours_of_operation.hours_of_operation_id
}

output "queue_authenticated_id" {
  description = "The identifier of the authenticated queue"
  value       = module.queue_authenticated.queue_id
}

output "queue_unknown_id" {
  description = "The identifier of the unknown queue"
  value       = module.queue_unknown.queue_id
}

output "routing_profile_id" {
  description = "The identifier of the routing profile"
  value       = module.routing_profile.routing_profile_id
}

output "user_id" {
  description = "The identifier of the user"
  value       = module.user.user_id
}

output "user_arn" {
  description = "The ARN of the user"
  value       = module.user.user_arn
}
