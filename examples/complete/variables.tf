variable "region" {
  type        = string
  description = "AWS region"
}

variable "create_sns_topic" {
  description = "Flag to indicate whether an SNS topic should be created for notifications."
  type        = bool
  default     = true
}

variable "enable_cloudwatch" {
  description = "Flag to indicate whether CloudWatch logging should be enabled for GuardDuty"
  type        = bool
  default     = true
}

variable "cloudwatch_event_rule_pattern_detail_type" {
  description = "The detail-type pattern used to match events that will be sent to SNS"
  type        = string
  default     = "GuardDuty Finding"
}

variable "finding_publishing_frequency" {
  description = "The frequency of notifications sent for finding occurrences"
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "subscribers" {
  type = map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
  }))
  description = "A map of subscription configurations for SNS topics"
  default     = {}
}

variable "s3_protection_enabled" {
  description = "Flag to indicate whether S3 protection will be turned on in GuardDuty"
  type        = bool
  default     = true
}

variable "kubernetes_audit_logs_enabled" {
  type        = bool
  default     = true
  description = "If true, enables Kubernetes audit logs as a data source for Kubernetes protection"
}

variable "malware_protection_scan_ec2_ebs_volumes_enabled" {
  type        = bool
  default     = true
  description = "Configure whether Malware Protection is enabled as data source for EC2 instances EBS Volumes"
}

variable "lambda_network_logs_enabled" {
  type        = bool
  default     = true
  description = "If true, enables Lambda network logs as a data source for Lambda protection"
}

variable "runtime_monitoring_enabled" {
  type        = bool
  default     = true
  description = "If true, enables Runtime Monitoring for EC2, ECS, and EKS resources"
}

variable "eks_runtime_monitoring_enabled" {
  type        = bool
  default     = false
  description = "If true, enables EKS Runtime Monitoring (cannot be used with runtime_monitoring_enabled)"
}

variable "runtime_monitoring_additional_config" {
  type = object({
    eks_addon_management_enabled         = optional(bool, false)
    ecs_fargate_agent_management_enabled = optional(bool, false)
    ec2_agent_management_enabled         = optional(bool, false)
  })
  default = {
    eks_addon_management_enabled         = true
    ecs_fargate_agent_management_enabled = true
    ec2_agent_management_enabled         = true
  }
  nullable    = false
  description = "Additional configuration for Runtime Monitoring features"
}
