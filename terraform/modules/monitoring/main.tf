
# --------------------------------------------------
# 1. ECS Backend CPU Utilization Alarm
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  alarm_description   = "ECS backend CPU utilization is too high"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period             = 300
  evaluation_periods = 2
  threshold          = 80
  treat_missing_data = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

# --------------------------------------------------
# 2. ECS Backend Memory Utilization Alarm
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-high"
  alarm_description   = "ECS backend memory utilization is too high"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  namespace   = "AWS/ECS"
  metric_name = "MemoryUtilization"
  statistic   = "Average"

  period             = 300
  evaluation_periods = 2
  threshold          = 80
  treat_missing_data = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

# --------------------------------------------------
# 3. ALB Unhealthy Targets Alarm
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-targets"
  alarm_description   = "One or more backend targets are unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Maximum"

  period             = 300
  evaluation_periods = 2
  threshold          = 1
  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

# --------------------------------------------------
# 4. ALB HTTP 5XX Errors Alarm
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_http_5xx" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-http-5xx"
  alarm_description   = "The Application Load Balancer is returning HTTP 5XX errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"

  period             = 300
  evaluation_periods = 2
  threshold          = 5
  treat_missing_data = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# --------------------------------------------------
# 5. RDS High CPU Utilization Alarm
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-cpu-high"
  alarm_description   = "RDS database CPU utilization is too high"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period             = 300
  evaluation_periods = 2
  threshold          = 80
  treat_missing_data = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# --------------------------------------------------
# 6. RDS Low Free Storage Alarm
# --------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-storage"
  alarm_description   = "RDS database free storage is below 2 GB"
  comparison_operator = "LessThanThreshold"

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"
  statistic   = "Minimum"

  period             = 300
  evaluation_periods = 2
  threshold          = 2147483648
  treat_missing_data = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}
