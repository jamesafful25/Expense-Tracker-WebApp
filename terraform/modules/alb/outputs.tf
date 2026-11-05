output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.backend.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.backend.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.backend.dns_name
}

output "target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}


output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer for CloudWatch metrics"
  value       = aws_lb.backend.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the backend target group for CloudWatch metrics"
  value       = aws_lb_target_group.backend.arn_suffix
}
