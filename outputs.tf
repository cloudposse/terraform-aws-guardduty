output "guardduty_detector" {
  description = "GuardDuty detector"
  value       = module.this.enabled ? aws_guardduty_detector.guardduty : null
}

output "sns_topic" {
  description = "SNS topic"
  value       = local.create_sns_topic ? module.sns_topic[0].sns_topic : null
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = local.create_sns_topic ? module.sns_topic[0].aws_sns_topic_subscriptions : null
}
