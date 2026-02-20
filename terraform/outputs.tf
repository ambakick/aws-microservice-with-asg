output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.microservices.id
}

output "launch_template_latest_version" {
  description = "Latest Launch Template version"
  value       = aws_launch_template.microservices.latest_version
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.microservices.name
}

output "target_group_service1_arn" {
  description = "Existing target group ARN for service1"
  value       = data.aws_lb_target_group.service1.arn
}

output "target_group_service2_arn" {
  description = "Existing target group ARN for service2"
  value       = data.aws_lb_target_group.service2.arn
}

output "scale_out_policy_arn" {
  description = "Scale-out policy ARN"
  value       = aws_autoscaling_policy.scale_out.arn
}

output "cpu_alarm_name" {
  description = "CloudWatch CPU alarm name"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}
