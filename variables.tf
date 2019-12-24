variable "function_name" {
  description = "The name of the Lambda function to monitor memory usage"
}

variable "sns_topic_name" {
  description = "The name of the SNS topic to deliver CloudWatch alerts"
}

variable "metrics_namespace" {
  description = "The name of the CloudWatch metrics namespace"
  default     = "ConcurrencyLabs/Lambda/"
}

variable "threshold_percent" {
  description = "The threshold of function memory usage in percent to fire a CloudWatch alarm"
  default     = 70
}

variable "period" {
  description = "The period in seconds over which the specified threshold is applied. (CloudWatch Alarm)"
  default     = 300
}
variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold. (CloudWatch Alarm)"
  default     = 1
}

variable "tags" {
  type    = "map"
  default = {}
}