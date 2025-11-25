region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"
name        = "guardduty"

# SNS and CloudWatch configuration
create_sns_topic                          = true
enable_cloudwatch                         = true
cloudwatch_event_rule_pattern_detail_type = "GuardDuty Finding"
finding_publishing_frequency              = "FIFTEEN_MINUTES"

# GuardDuty detector features
s3_protection_enabled                           = true
kubernetes_audit_logs_enabled                   = true
malware_protection_scan_ec2_ebs_volumes_enabled = true
lambda_network_logs_enabled                     = true
runtime_monitoring_enabled                      = true
eks_runtime_monitoring_enabled                  = false

# Runtime Monitoring additional configuration
runtime_monitoring_additional_config = {
  eks_addon_management_enabled         = true
  ecs_fargate_agent_management_enabled = true
  ec2_agent_management_enabled         = true
}
