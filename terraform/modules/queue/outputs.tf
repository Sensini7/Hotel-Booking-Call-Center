output "queue_id" {
  description = "The identifier of the queue"
  value       = aws_connect_queue.this.queue_id
}

output "queue_arn" {
  description = "The Amazon Resource Name (ARN) of the queue"
  value       = aws_connect_queue.this.arn
}
