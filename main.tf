#-----------------------------------------------------------------------------------------------------------------------
# Subscribe the Acccount to GuardDuty
#-----------------------------------------------------------------------------------------------------------------------
resource "aws_guardduty_detector" "guardduty" {
  enable                       = module.this.enabled
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = var.s3_protection_enabled
    }

    kubernetes {
      audit_logs {
        enable = var.kubernetes_protection_enabled
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.malware_protection_enabled
        }
      }
    }
  }

  tags = module.this.tags
}

#-----------------------------------------------------------------------------------------------------------------------
# Optionally configure Runtime Monitoring for EKS, ECS Fargate or EC2
# https://docs.aws.amazon.com/guardduty/latest/ug/enable-runtime-monitoring-standalone-acc.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature
#-----------------------------------------------------------------------------------------------------------------------

resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  count       = var.enable_eks_runtime_monitor ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}

resource "aws_guardduty_detector_feature" "fargate_runtime_monitoring" {
  count       = var.enable_fargate_runtime_monitor ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = "ENABLED"
  }
}

resource "aws_guardduty_detector_feature" "ec2_runtime_monitoring" {
  count       = var.enable_ec2_runtime_monitor ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EC2_AGENT_MANAGEMENT"
    status = "ENABLED"
  }
}

resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  count       = var.enable_eks_audit_logs ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  count       = var.enable_ebs_malware_protection ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "rds_login_events" {
  count       = var.enable_rds_login_events ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "RDS_LOGIN_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "lambda_network_logs" {
  count       = var.enable_lambda_network_logs ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  count       = var.enable_s3_data_events ? 1 : 0
  detector_id = aws_guardduty_detector.guardduty.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}
#-----------------------------------------------------------------------------------------------------------------------
# Optionally configure Event Bridge Rules and SNS subscriptions
# https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cwe-integration-types.html
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/resource-based-policies-cwe.html#sns-permissions
#-----------------------------------------------------------------------------------------------------------------------
module "sns_topic" {

  source  = "cloudposse/sns-topic/aws"
  version = "0.20.1"
  count   = local.create_sns_topic ? 1 : 0

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
