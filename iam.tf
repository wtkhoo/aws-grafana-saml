# IAM role for Grafana to read data source
resource "aws_iam_role" "grafana" {
  name = "grafana_assume_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "grafana_assume_policy" {
  name = "grafana_assume_policy"
  role = aws_iam_role.grafana.id

  policy = data.aws_iam_policy_document.grafana_assume_policy.json

}

# Grant AWS Grafana to read CloudWatch metrics and EC2
data "aws_iam_policy_document" "grafana_assume_policy" {
  statement {
    sid = "AllowReadingMetricsFromCloudWatch"
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    sid = "AllowReadingTagsInstancesRegionsFromEC2"
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    sid = "AllowReadingResourcesForTags"
    actions = [
      "tag:GetResources"
    ]

    resources = [
      "*"
    ]
  }
}