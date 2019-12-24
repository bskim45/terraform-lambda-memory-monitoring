locals {
  // REPORT RequestId: 895ecd24-501b-485a-9329-fcb7ce9ad943	Duration: 3.66 ms	Billed Duration: 100 ms	Memory Size: 256 MB	Max Memory Used: 146 MB	Init Duration: 554.57 ms	
  metrics_pattern           = "[report_name=\"REPORT\", request_id_name=\"RequestId:\", request_id_value, duration_name=\"Duration:\", duration_value, duration_unit=\"ms\", billed_duration_name_1=\"Billed\", bill_duration_name_2=\"Duration:\", billed_duration_value, billed_duration_unit=\"ms\", memory_size_name_1=\"Memory\", memory_size_name_2=\"Size:\", memory_size_value, memory_size_unit=\"MB\", max_memory_used_name_1=\"Max\", max_memory_used_name_2=\"Memory\", max_memory_used_name_3=\"Used:\", max_memory_used_value, max_memory_used_unit=\"MB\", xray_trace_id_name_1=\"XRAY\", xray_trace_id_name_2=\"TraceId:\", xray_trace_id_value, xray_segment_id_name=\"SegmentId:\", xray_segment_id_value]"
  cloudwatch_log_group_name = "/aws/lambda/${var.function_name}"
}

data "aws_lambda_function" "this" {
  function_name = "${var.function_name}"
}

data "aws_sns_topic" "this" {
  name = "${var.sns_topic_name}"
}

data "aws_cloudwatch_log_group" "this" {
  name = "${local.cloudwatch_log_group_name}"
}

resource "aws_cloudwatch_log_metric_filter" "calculator-memory-used" {
  name           = "${var.function_name}-memory-used"
  log_group_name = "${local.cloudwatch_log_group_name}"

  pattern = "${local.metrics_pattern}"

  metric_transformation {
    name      = "MemoryUsed-${var.function_name}"
    namespace = "${var.metrics_namespace}"
    value     = "$max_memory_used_value"
  }
}

resource "aws_cloudwatch_log_metric_filter" "calculator-memory-size" {
  name           = "${var.function_name}-memory-size"
  log_group_name = "${local.cloudwatch_log_group_name}"

  pattern = "${local.metrics_pattern}"

  metric_transformation {
    name      = "MemorySize-${var.function_name}"
    namespace = "${var.metrics_namespace}"
    value     = "$memory_size_value"
  }
}

resource "aws_cloudwatch_metric_alarm" "calculator_memory_alarm" {
  alarm_name                = "${var.function_name}-memory-usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "${var.evaluation_periods}"
  threshold                 = "${var.threshold_percent}"
  alarm_description         = "Lambda memory usage has exceeded ${var.threshold_percent}%"
  insufficient_data_actions = []

  alarm_actions = [
    "${data.aws_sns_topic.this.arn}"
  ]

  tags = "${var.tags}"

  metric_query {
    id          = "e1"
    expression  = "(m2/m1)*100"
    label       = "MemoryUsedPercent"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "MemorySize-${var.function_name}"
      namespace   = "${var.metrics_namespace}"
      period      = "${var.period}"
      stat        = "Maximum"
    }
  }
  metric_query {
    id = "m2"
    metric {
      metric_name = "MemoryUsed-${var.function_name}"
      namespace   = "${var.metrics_namespace}"
      period      = "${var.period}"
      stat        = "Maximum"
    }
  }
}