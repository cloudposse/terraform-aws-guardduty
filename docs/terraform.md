<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 2 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| findings_label | cloudposse/label/null | 0.24.1 |
| sns_topic | cloudposse/sns-topic/aws | 0.16.0 |
| this | cloudposse/label/null | 0.24.1 |

## Resources

| Name |
|------|
| [aws_cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) |
| [aws_cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) |
| [aws_guardduty_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| cloudwatch\_event\_rule\_pattern\_detail\_type | The detail-type pattern used to match events that will be sent to SNS. <br><br>For more information, see:<br>https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html<br>https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html<br>https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html | `string` | `"GuardDuty Finding"` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| create\_sns\_topic | Flag to indicate whether an SNS topic should be created for notifications.<br>If you want to send findings to a new SNS topic, set this to true and provide a valid configuration for subscribers. | `bool` | `false` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| finding\_publishing\_frequency | The frequency of notifications sent for finding occurrences. If the detector is a GuardDuty member account, the value <br>is determined by the GuardDuty master account and cannot be modified, otherwise it defaults to SIX\_HOURS. <br><br>For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection. <br>Valid values for standalone and master accounts: FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS."<br><br>For more information, see:<br>https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency | `string` | `null` | no |
| findings\_notification\_arn | The ARN for an SNS topic to send findings notifications to. This is only used if create\_sns\_topic is false.<br>If you want to send findings to an existing SNS topic, set the value of this to the ARN of the existing topic and set <br>create\_sns\_topic to false. | `string` | `null` | no |
| id\_length\_limit | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| label\_key\_case | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| label\_value\_case | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| subscribers | A map of subscription configurations for SNS topics<br><br>For more information, see:<br>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference<br> <br>protocol:       <br>  The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially <br>  supported, see link) (email is an option but is unsupported in terraform, see link).<br>endpoint:       <br>  The endpoint to send data to, the contents will vary with the protocol. (see link for more information)<br>endpoint\_auto\_confirms:<br>  Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is <br>  false<br>raw\_message\_delivery:<br>  Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property). <br>  Default is false | <pre>map(object({<br>    protocol               = string<br>    endpoint               = string<br>    endpoint_auto_confirms = bool<br>    raw_message_delivery   = bool<br>  }))</pre> | `{}` | no |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| guardduty\_detector | GuardDuty detector |
| sns\_topic | SNS topic |
| sns\_topic\_subscriptions | SNS topic subscriptions |
<!-- markdownlint-restore -->
