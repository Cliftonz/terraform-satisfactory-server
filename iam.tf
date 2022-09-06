module "iam_policy" {
  source  = "cloudposse/iam-policy/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "0.4.0"

  iam_policy_statements = {
    # TODO: Tighten Access
    FullAccessEfs = {
      effect     = "Allow"
      actions    = ["elasticfilesystem:*"]
      resources  = ["*"]
      conditions = []
    },
    logs = {
      effect     = "Allow"
      actions    = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources  = [
        aws_cloudwatch_log_group.Satisfactory_Server.arn
      ]
      conditions = []
    },
  }
}



data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ecs.amazonaws.com",
        "events.amazonaws.com",
        "elasticfilesystem.amazonaws.com"
      ]
    }
  }
}

module "role" {
  source = "cloudposse/iam-role/aws"
  version     = "0.16.2"

  enabled   = true
  namespace = local.namespace
  stage     = local.stage
  name      = format("%s_role", local.appName)

  policy_description = "Allow ECS, Cloudwatch, and efs Access"
  role_description   = "IAM role with permissions to perform actions on ecs services, ecs tasks, put cloudwatch logs to Satisfactory group, and communicate to efs."
  
  policy_documents = [
    data.aws_iam_policy_document.assume_role
  ]

  depends_on = [
    data.aws_iam_policy_document.assume_role,
    module.iam_policy
  ]

}
