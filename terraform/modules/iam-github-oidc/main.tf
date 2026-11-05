
# --------------------------------------------------
# GitHub Actions OIDC Identity Provider
# --------------------------------------------------

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# --------------------------------------------------
# GitHub Actions Trust Policy
# --------------------------------------------------

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

# --------------------------------------------------
# GitHub Actions IAM Role
# --------------------------------------------------

resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-actions-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------
# AWS Account Information
# --------------------------------------------------

data "aws_caller_identity" "current" {}

# --------------------------------------------------
# GitHub Actions Deployment Permissions
# --------------------------------------------------

data "aws_iam_policy_document" "github_actions_deployment" {

  # Frontend S3 bucket access
  statement {
    sid    = "FrontendBucketAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.frontend_bucket_name}"
    ]
  }

  # Frontend object upload and deletion
  statement {
    sid    = "FrontendObjectAccess"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]

    resources = [
      "arn:aws:s3:::${var.frontend_bucket_name}/*"
    ]
  }

  # CloudFront cache invalidation
  statement {
    sid    = "CloudFrontInvalidation"
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_id}"
    ]
  }

  # ECR authentication
  statement {
    sid    = "ECRAuthentication"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  # ECR image push permissions
  statement {
    sid    = "ECRImagePush"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}-${var.environment}-backend"
    ]
  }

  # ECS task definition registration and inspection
  statement {
    sid    = "ECSTaskDefinition"
    effect = "Allow"

    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition"
    ]

    resources = ["*"]
  }

  # ECS cluster and service inspection
  statement {
    sid    = "ECSServiceInspection"
    effect = "Allow"

    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices"
    ]

    resources = ["*"]
  }

  # Read ALB target group information and inspect backend target health
  statement {
    sid    = "ALBTargetHealthInspection"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth"
    ]

    resources = ["*"]
  }

  # Run only the intended database migration task
  statement {
    sid    = "ECSDatabaseMigration"
    effect = "Allow"

    actions = [
      "ecs:RunTask"
    ]

    resources = [
      "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.project_name}-${var.environment}-db-migration:*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"

      values = [
        "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}-${var.environment}-cluster"
      ]
    }
  }

  # Inspect migration tasks only within the intended ECS cluster
  statement {
    sid    = "ECSDatabaseMigrationInspection"
    effect = "Allow"

    actions = [
      "ecs:DescribeTasks"
    ]

    resources = [
      "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task/${var.project_name}-${var.environment}-cluster/*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"

      values = [
        "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}-${var.environment}-cluster"
      ]
    }
  }

  # Update only the intended ECS service
  statement {
    sid    = "ECSServiceDeployment"
    effect = "Allow"

    actions = [
      "ecs:UpdateService"
    ]

    resources = [
      "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.project_name}-${var.environment}-cluster/${var.project_name}-${var.environment}-backend-service"
    ]
  }

  # Allow passing only the four intended ECS task roles
  statement {
    sid    = "PassECSTaskRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-ecs-execution-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-ecs-task-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-migration-execution-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.environment}-migration-task-role"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# --------------------------------------------------
# Attach Deployment Policy to GitHub Actions Role
# --------------------------------------------------

resource "aws_iam_role_policy" "github_actions_deployment" {
  name   = "${var.project_name}-${var.environment}-github-actions-deployment"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_deployment.json
}
