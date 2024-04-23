variable "region" {
  type        = string
  description = "AWS region"
}

variable "create_sns_topic" {
  description = "Flag to indicate whether an SNS topic should be created for notifications."
  type        = bool
  default     = false
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

variable "malware_protection_scan_ec2_ebs_volumes_enabled" {
  type        = bool
  description = <<-DOC
  Configure whether Malware Protection is enabled as data source for EC2 instances EBS Volumes in GuardDuty.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#malware-protection
  DOC
  default     = false
}

variable "kubernetes_audit_logs_enabled" {
  type        = bool
  description = <<-DOC
  If true, enables Kubernetes audit logs as a data source for Kubernetes protection.

  For more information, see:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#kubernetes-audit-logs
  DOC
  default     = false
}
