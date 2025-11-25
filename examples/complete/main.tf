provider "aws" {
  region = var.region
}

module "guardduty" {
  source = "../.."

  # SNS and CloudWatch configuration
  create_sns_topic                          = var.create_sns_topic
  enable_cloudwatch                         = var.enable_cloudwatch
  cloudwatch_event_rule_pattern_detail_type = var.cloudwatch_event_rule_pattern_detail_type
  finding_publishing_frequency              = var.finding_publishing_frequency
  subscribers                               = var.subscribers

  # GuardDuty detector feature flags
  s3_protection_enabled                           = var.s3_protection_enabled
  kubernetes_audit_logs_enabled                   = var.kubernetes_audit_logs_enabled
  malware_protection_scan_ec2_ebs_volumes_enabled = var.malware_protection_scan_ec2_ebs_volumes_enabled
  lambda_network_logs_enabled                     = var.lambda_network_logs_enabled
  runtime_monitoring_enabled                      = var.runtime_monitoring_enabled
  eks_runtime_monitoring_enabled                  = var.eks_runtime_monitoring_enabled
  runtime_monitoring_additional_config            = var.runtime_monitoring_additional_config

  context = module.this.context
}
