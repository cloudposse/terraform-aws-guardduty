provider "aws" {
  region = var.region
}

module "guardduty" {
  source = "../.."

  create_sns_topic                                = var.create_sns_topic
  s3_protection_enabled                           = var.s3_protection_enabled
  malware_protection_scan_ec2_ebs_volumes_enabled = var.malware_protection_scan_ec2_ebs_volumes_enabled
  kubernetes_audit_logs_enabled                   = var.kubernetes_audit_logs_enabled

  context = module.this.context
}
