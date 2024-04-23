region      = "us-east-2"
namespace   = "eg"
environment = "ue2"
stage       = "test"

create_sns_topic                                = true
s3_protection_enabled                           = true
malware_protection_scan_ec2_ebs_volumes_enabled = true
kubernetes_audit_logs_enabled                   = true
