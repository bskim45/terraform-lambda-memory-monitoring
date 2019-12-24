output "metric_alarm_arn" {
  description = "The ARN of the CloudWatch Metric Alarm"
  value       = "${aws_cloudwatch_metric_alarm.calculator_memory_alarm.arn}"
}