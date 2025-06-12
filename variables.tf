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

variable "kubernetes_protection_enabled" {
  description = <<-DOC
  Flag to indicate whether EKS Protection with EKS Audit Log Monitoring Configuration will be turned on in GuardDuty.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector
  DOC
  type        = bool
  default     = false
}

variable "malware_protection_enabled" {
  description = <<-DOC
  Flag to indicate whether Malware Protection for EC2 will be turned on in GuardDuty.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector
  DOC
  type        = bool
  default     = false
}

variable "enable_eks_runtime_monitor" {
  description = <<-DOC
  Flag to indicate whether EKS Runtime Monitoring will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}

variable "enable_fargate_runtime_monitor" {
  description = <<-DOC
  Flag to indicate whether ECS Fargate Runtime Monitoring will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}

variable "enable_ec2_runtime_monitor" {
  description = <<-DOC
  Flag to indicate whether EC2 Runtime Monitoring will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}

variable "enable_eks_audit_logs" {
  description = <<-DOC
  Flag to indicate whether EKS Audit Logs will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}

variable "enable_ebs_malware_protection" {
  description = <<-DOC
  Flag to indicate whether EKS Audit Logs will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}

variable "enable_rds_login_events" {
  description = <<-DOC
  Flag to indicate whether EKS Audit Logs will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}

variable "enable_lambda_network_logs" {
  description = <<-DOC
  Flag to indicate whether EKS Audit Logs will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}

variable "enable_s3_data_events" {
  description = <<-DOC
  Flag to indicate whether EKS Audit Logs will be enabled in GuardDuty.

  For more information, see:
  https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  DOC
  type        = bool
  default     = false
}
