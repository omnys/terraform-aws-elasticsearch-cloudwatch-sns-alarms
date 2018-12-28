locals {
  thresholds = {
    FreeStorageSpaceThreshold        = "${max(var.free_storage_space_threshold, 0)}"
    MinimumAvailableNodes            = "${max(var.min_available_nodes, 0)}"
    CPUUtilizationThreshold          = "${min(max(var.cpu_utilization_threshold, 0), 100)}"
    JVMMemoryPressureThreshold       = "${min(max(var.jvm_memory_pressure_threshold, 0), 100)}"
    MasterCPUUtilizationThreshold    = "${min(max(coalesce(var.master_cpu_utilization_threshold, var.cpu_utilization_threshold), 0), 100)}"
    MasterJVMMemoryPressureThreshold = "${min(max(coalesce(var.master_jvm_memory_pressure_threshold, var.jvm_memory_pressure_threshold), 0), 100)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_is_red" {
  count               = "${var.monitor_cluster_status_is_red}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-ClusterStatusIsRed${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Average elasticsearch cluster status is in red over last 5 minutes"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_is_yellow" {
  count               = "${var.monitor_cluster_status_is_yellow}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-ClusterStatusIsYellow${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Average elasticsearch cluster status is in yellow over last 5 minutes"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  count               = "${var.monitor_free_storage_space_too_low}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-FreeStorageSpaceTooLow${var.alarm_name_postfix}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Average"
  threshold           = "${local.thresholds["FreeStorageSpaceThreshold"]}"
  alarm_description   = "Average elasticsearch free storage space over last 1 minutes is too low"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_index_writes_blocked" {
  count               = "${var.monitor_cluster_index_writes_blocked}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-ClusterIndexWritesBlocked${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterIndexWritesBlocked"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Elasticsearch index writes being blocker over last 10 minutes"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "insufficient_available_nodes" {
  count               = "${var.monitor_insufficient_available_nodes}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-InsufficientAvailableNodes${var.alarm_name_postfix}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Nodes"
  namespace           = "AWS/ES"
  period              = "86400"
  statistic           = "Minimum"
  threshold           = "${local.thresholds["MinimumAvailableNodes"]}"
  alarm_description   = "Elasticsearch nodes minimum < ${local.thresholds["MinimumAvailableNodes"]} for 1 day"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "automated_snapshot_failure" {
  count               = "${var.monitor_automated_snapshot_failure}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-AutomatedSnapshotFailure${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "AutomatedSnapshotFailure"
  namespace           = "AWS/ES"
  period              = "600"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Elasticsearch automated snapshot failed over last 10 minutes"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  count               = "${var.monitor_cpu_utilization_too_high}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-CPUUtilizationTooHigh${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = "900"
  statistic           = "Average"
  threshold           = "${local.thresholds["CPUUtilizationThreshold"]}"
  alarm_description   = "Average elasticsearch cluster CPU utilization over last 10 minutes too high"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "jvm_memory_pressure_too_high" {
  count               = "${var.monitor_jvm_memory_pressure_too_high}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-JVMMemoryPressure${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "JVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = "900"
  statistic           = "Maximum"
  threshold           = "${local.thresholds["JVMMemoryPressureThreshold"]}"
  alarm_description   = "Elasticsearch JVM memory pressure is too high over last 10 minutes"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "master_cpu_utilization_too_high" {
  count               = "${var.monitor_master_cpu_utilization_too_high}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-MasterCPUUtilizationTooHigh${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MasterCPUUtilization"
  namespace           = "AWS/ES"
  period              = "900"
  statistic           = "Average"
  threshold           = "${local.thresholds["MasterCPUUtilizationThreshold"]}"
  alarm_description   = "Average elasticsearch cluster CPU utilization over last 10 minutes too high"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "master_jvm_memory_pressure_too_high" {
  count               = "${var.monitor_master_jvm_memory_pressure_too_high}"
  alarm_name          = "${var.alarm_name_prefix}ElasticSearch-JVMMemoryPressure${var.alarm_name_postfix}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MasterJVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = "900"
  statistic           = "Maximum"
  threshold           = "${local.thresholds["MasterJVMMemoryPressureThreshold"]}"
  alarm_description   = "Elasticsearch JVM memory pressure is too high over last 10 minutes"
  alarm_actions       = ["${local.aws_sns_topic_arn}"]
  ok_actions          = ["${local.aws_sns_topic_arn}"]

  dimensions {
    DomainName = "${var.domain_name}"
    ClientId   = "${data.aws_caller_identity.default.account_id}"
  }
}