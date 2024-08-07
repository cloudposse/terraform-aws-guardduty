output "guardduty_detector" {
  description = "GuardDuty detector"
  value       = module.guardduty.guardduty_detector
}
output "sns_topic" {
  description = "SNS topic"
  value       = module.guardduty.sns_topic
}
