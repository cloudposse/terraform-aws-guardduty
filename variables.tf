variable "enable_cloudwatch" {
  description = <<-DOC
  Flag to indicate whether an CloudWatch logging should be enabled for GuardDuty
  DOC
  type        = bool
  default     = false
}

variable "cloudwatch_event_rule_pattern_detail_type" {
  description = <<-DOC
  The detail-type pattern used to match events that will be sent to SNS.

  For more information, see:
  https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html
  https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html
  DOC
  type        = string
  default     = "GuardDuty Finding"
}

variable "create_sns_topic" {
  description = <<-DOC
  Flag to indicate whether an SNS topic should be created for notifications.
  If you want to send findings to a new SNS topic, set this to true and provide a valid configuration for subscribers.
  DOC

  type    = bool
  default = false
}

variable "subscribers" {
  type = map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
  }))
  description = <<-DOC
  A map of subscription configurations for SNS topics

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference

  protocol:
    The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially
    supported, see link) (email is an option but is unsupported in terraform, see link).
  endpoint:
    The endpoint to send data to, the contents will vary with the protocol. (see link for more information)
  endpoint_auto_confirms:
    Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is
    false
  raw_message_delivery:
    Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property).
    Default is false
  DOC
  default     = {}
}

variable "findings_notification_arn" {
  description = <<-DOC
  The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.
  If you want to send findings to an existing SNS topic, set the value of this to the ARN of the existing topic and set
  create_sns_topic to false.
  DOC
  default     = null
  type        = string
}

variable "finding_publishing_frequency" {
  description = <<-DOC
  The frequency of notifications sent for finding occurrences. If the detector is a GuardDuty member account, the value
  is determined by the GuardDuty master account and cannot be modified, otherwise it defaults to SIX_HOURS.

  For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.
  Valid values for standalone and master accounts: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency
  DOC
  type        = string
  default     = null
}

variable "s3_protection_enabled" {
  description = <<-DOC
  Flag to indicate whether S3 protection will be turned on in GuardDuty.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector
  DOC
  type        = bool
  default     = false
}

variable "detector_feature" {
  type = map(object({
    feature_name = string
    status       = string
    additional_configuration = optional(object({
      addon_name = string
      status     = string
    }))
  }))
  default     = {}
  description = <<-DOC
  A map of detector features for streaming foundational data sources to detect communication with known malicious domains and IP addresses and identify anomalous behavior.
  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/guardduty-features-activation-model.html#guardduty-features
  feature_name:
    The name of the detector feature. Possible values include: S3_DATA_EVENTS, EKS_AUDIT_LOGS, EBS_MALWARE_PROTECTION, RDS_LOGIN_EVENTS, EKS_RUNTIME_MONITORING, LAMBDA_NETWORK_LOGS, RUNTIME_MONITORING. Specifying both EKS Runtime Monitoring (EKS_RUNTIME_MONITORING) and Runtime Monitoring (RUNTIME_MONITORING) will cause an error. You can add only one of these two features because Runtime Monitoring already includes the threat detection for Amazon EKS resources. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorFeatureConfiguration.html.
  status:
    The status of the detector feature. Valid values include: ENABLED or DISABLED.
  additional_configuration:
    Optional information about the additional configuration for a feature in your GuardDuty account. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorAdditionalConfiguration.html.
  addon_name:
    The name of the add-on for which the configuration applies. Possible values include: EKS_ADDON_MANAGEMENT, ECS_FARGATE_AGENT_MANAGEMENT, and EC2_AGENT_MANAGEMENT. For more information, see: https://docs.aws.amazon.com/guardduty/latest/APIReference/API_DetectorAdditionalConfiguration.html.
  status:
    The status of the add-on. Valid values include: ENABLED or DISABLED.
  DOC
}
