output "guardduty_detector" {
  description = "GuardDuty detector"
  value       = module.guardduty.guardduty_detector
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = module.guardduty.guardduty_detector.id
}

output "guardduty_detector_arn" {
  description = "The ARN of the GuardDuty detector"
  value       = module.guardduty.guardduty_detector.arn
}

output "sns_topic" {
  description = "SNS topic"
  value       = module.guardduty.sns_topic
}

output "sns_topic_subscriptions" {
  description = "SNS topic subscriptions"
  value       = module.guardduty.sns_topic_subscriptions
}
