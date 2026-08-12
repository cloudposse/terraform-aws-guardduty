#-----------------------------------------------------------------------------------------------------------------------
# Subscribe the Account to GuardDuty
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_guardduty_detector" "guardduty" {
  enable                       = module.this.enabled
  finding_publishing_frequency = var.finding_publishing_frequency

  # Note: The datasources block is deprecated in favor of aws_guardduty_detector_feature resources
  # See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature

  tags = module.this.tags
}

#-----------------------------------------------------------------------------------------------------------------------
# Configure detector features using the new resource type
# This replaces the deprecated datasources block
#-----------------------------------------------------------------------------------------------------------------------

# S3 Data Events protection
resource "aws_guardduty_detector_feature" "s3_data_events" {
  count = module.this.enabled && var.s3_protection_enabled ? 1 : 0

  detector_id = aws_guardduty_detector.guardduty.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

# EKS Audit Logs
resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  count = module.this.enabled && var.kubernetes_audit_logs_enabled ? 1 : 0

  detector_id = aws_guardduty_detector.guardduty.id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

# EBS Malware Protection
resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  count = module.this.enabled && var.malware_protection_scan_ec2_ebs_volumes_enabled ? 1 : 0

  detector_id = aws_guardduty_detector.guardduty.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

# RDS Login Events - Organization-only feature
# Note: RDS_LOGIN_EVENTS can only be configured at the organization level via
# aws_guardduty_organization_configuration_feature, not at the detector level.
# This feature is configured in the parent component during Step 3 (org-settings).

# Lambda Network Logs
resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  count = module.this.enabled && var.lambda_network_logs_enabled ? 1 : 0

  detector_id = aws_guardduty_detector.guardduty.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "ENABLED"
}

# Runtime Monitoring (includes EC2, ECS, and EKS)
# Note: Do not enable both RUNTIME_MONITORING and EKS_RUNTIME_MONITORING
resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  count = module.this.enabled && var.runtime_monitoring_enabled ? 1 : 0

  detector_id = aws_guardduty_detector.guardduty.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  # Use dynamic blocks with explicit list ordering to avoid order-based drift
  # AWS returns these in this specific order: EKS, EC2, ECS (not alphabetical)
  dynamic "additional_configuration" {
    for_each = [
      {
        name   = "EKS_ADDON_MANAGEMENT"
        status = var.runtime_monitoring_additional_config.eks_addon_management_enabled ? "ENABLED" : "DISABLED"
      },
      {
        name   = "EC2_AGENT_MANAGEMENT"
        status = var.runtime_monitoring_additional_config.ec2_agent_management_enabled ? "ENABLED" : "DISABLED"
      },
      {
        name   = "ECS_FARGATE_AGENT_MANAGEMENT"
        status = var.runtime_monitoring_additional_config.ecs_fargate_agent_management_enabled ? "ENABLED" : "DISABLED"
      },
    ]

    content {
      name   = additional_configuration.value.name
      status = additional_configuration.value.status
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.runtime_monitoring_enabled && var.eks_runtime_monitoring_enabled)
      error_message = "Cannot enable both RUNTIME_MONITORING and EKS_RUNTIME_MONITORING. Runtime Monitoring already includes threat detection for Amazon EKS resources."
    }
  }
}

# EKS Runtime Monitoring (standalone)
# Note: Do not enable both RUNTIME_MONITORING and EKS_RUNTIME_MONITORING
resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  count = module.this.enabled && var.eks_runtime_monitoring_enabled ? 1 : 0

  detector_id = aws_guardduty_detector.guardduty.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  # EKS Runtime Monitoring only supports EKS_ADDON_MANAGEMENT
  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = var.runtime_monitoring_additional_config.eks_addon_management_enabled ? "ENABLED" : "DISABLED"
  }

  lifecycle {
    precondition {
      condition     = !(var.runtime_monitoring_enabled && var.eks_runtime_monitoring_enabled)
      error_message = "Cannot enable both RUNTIME_MONITORING and EKS_RUNTIME_MONITORING. Runtime Monitoring already includes threat detection for Amazon EKS resources."
    }
  }
}

#-----------------------------------------------------------------------------------------------------------------------
# Optionally configure Event Bridge Rules and SNS subscriptions
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cwe-integration-types.html
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/resource-based-policies-cwe.html#sns-permissions
#-----------------------------------------------------------------------------------------------------------------------
module "sns_topic" {
  count = local.create_sns_topic ? 1 : 0

  source  = "cloudposse/sns-topic/aws"
  version = "1.2.0"

  subscribers     = var.subscribers
  sqs_dlq_enabled = false

  attributes = concat(module.this.attributes, ["guardduty"])
  context    = module.this.context
}

module "findings_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = concat(module.this.attributes, ["guardduty", "findings"])
  context    = module.this.context
}

resource "aws_sns_topic_policy" "sns_topic_publish_policy" {
  count  = module.this.enabled && local.create_sns_topic ? 1 : 0
  arn    = local.findings_notification_arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count     = module.this.enabled && local.create_sns_topic ? 1 : 0
  policy_id = "GuardDutyPublishToSNS"
  statement {
    sid = ""
    actions = [
      "sns:Publish"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    resources = [module.sns_topic[0].sns_topic.arn]
    effect    = "Allow"
  }
}

resource "aws_cloudwatch_event_rule" "findings" {
  count       = local.enable_cloudwatch == true ? 1 : 0
  name        = module.findings_label.id
  description = "GuardDuty Findings"
  tags        = module.this.tags

  event_pattern = jsonencode(
    {
      "source" : [
        "aws.guardduty"
      ],
      "detail-type" : [
        var.cloudwatch_event_rule_pattern_detail_type
      ]
    }
  )
}

resource "aws_cloudwatch_event_target" "imported_findings" {
  count = local.enable_notifications == true ? 1 : 0
  rule  = aws_cloudwatch_event_rule.findings[0].name
  arn   = local.findings_notification_arn
}

#-----------------------------------------------------------------------------------------------------------------------
# Locals and Data References
#-----------------------------------------------------------------------------------------------------------------------
locals {
  enable_cloudwatch         = module.this.enabled && (var.enable_cloudwatch || local.enable_notifications)
  enable_notifications      = module.this.enabled && (var.create_sns_topic || var.findings_notification_arn != null)
  create_sns_topic          = module.this.enabled && var.create_sns_topic
  findings_notification_arn = local.enable_notifications ? (var.findings_notification_arn != null ? var.findings_notification_arn : module.sns_topic[0].sns_topic.arn) : null
}
