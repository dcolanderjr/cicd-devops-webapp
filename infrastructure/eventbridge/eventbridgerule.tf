resource "aws_cloudwatch_event_rule" "ec2_state_changes_rule" {
  name = "EC2StateChangesRule"

  event_pattern = jsonencode({
    source      = ["aws.cloudtrail"],
    detail_type = ["AWS API Call via CloudTrail"],
    detail      = {
      eventSource = ["ec2.amazonaws.com"],
      eventName   = ["RunInstances", "StartInstances", "StopInstances", "TerminateInstances", "AssociateAddress", "DisassociateAddress"],
      resources   = ["arn:aws:ec2:*:*:instance/*", "arn:aws:ec2:*:*:elastic-ip/*"]
    }
  })
}
