# DELIBERATELY INSECURE IAM — for scanner testing only
# A range of wildcard / over-permissive IAM patterns,
# from blatant to subtle, to see what Checkov vs Trivy catch.

provider "aws" {
  region = "us-east-1"
}

# ── 1. FULL ADMIN WILDCARD (the blatant one) ─────────────
# Action: * on Resource: *  — god mode
resource "aws_iam_role" "full_admin" {
  name               = "full-admin-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy" "full_admin_policy" {
  name = "full-admin"
  role = aws_iam_role.full_admin.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Action = "*", Effect = "Allow", Resource = "*" }]
  })
}

# ── 2. SERVICE-LEVEL WILDCARD ────────────────────────────
# s3:* — every S3 action on every bucket
resource "aws_iam_role_policy" "s3_wildcard" {
  name = "s3-all-actions"
  role = aws_iam_role.full_admin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "s3:*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ── 3. WILDCARD RESOURCE ONLY ────────────────────────────
# Specific actions but on every resource
resource "aws_iam_role_policy" "wildcard_resource" {
  name = "specific-action-all-resources"
  role = aws_iam_role.full_admin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:GetObject", "s3:DeleteObject"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ── 4. PASSROLE WILDCARD (privilege escalation classic) ──
# iam:PassRole on * lets you hand any role to a service
resource "aws_iam_role_policy" "passrole_wildcard" {
  name = "passrole-anything"
  role = aws_iam_role.full_admin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["iam:PassRole", "ec2:RunInstances"]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ── 5. IAM FULL CONTROL (permission management) ──────────
# iam:* lets the holder rewrite all permissions
resource "aws_iam_role_policy" "iam_wildcard" {
  name = "iam-full-control"
  role = aws_iam_role.full_admin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "iam:*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ── 6. NOTACTION BYPASS PATTERN ──────────────────────────
# "Allow everything EXCEPT" — sneaky over-permission
resource "aws_iam_role_policy" "notaction_bypass" {
  name = "allow-all-except-iam"
  role = aws_iam_role.full_admin.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      NotAction = "iam:*"
      Effect    = "Allow"
      Resource  = "*"
    }]
  })
}

# ── 7. WILDCARD PRINCIPAL IN TRUST POLICY ────────────────
# Anyone in any AWS account can assume this role
resource "aws_iam_role" "wildcard_principal" {
  name = "anyone-can-assume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { AWS = "*" }
    }]
  })
}

# ── 8. MANAGED POLICY WITH WILDCARD ──────────────────────
resource "aws_iam_policy" "standalone_wildcard" {
  name = "standalone-admin"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ── 9. ATTACHED INLINE USER POLICY WILDCARD ──────────────
resource "aws_iam_user" "power_user" {
  name = "power-user"
}

resource "aws_iam_user_policy" "user_wildcard" {
  name = "user-god-mode"
  user = aws_iam_user.power_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ── shared assume-role document ──────────────────────────
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
