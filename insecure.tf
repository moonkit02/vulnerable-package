# DELIBERATELY INSECURE Terraform — for scanner testing only
# Tests three misconfiguration classes:
#   1. Public S3 bucket
#   2. Wildcard IAM role (Action: *, Resource: *)
#   3. Open CIDR (0.0.0.0/0) ingress

provider "aws" {
  region = "us-east-1"
}

# ── 1. PUBLIC S3 BUCKET ──────────────────────────────────
# Trivy should flag: public ACL, no block-public-access,
# no encryption, no logging
resource "aws_s3_bucket" "public_data" {
  bucket = "my-insecure-public-bucket"
}

resource "aws_s3_bucket_acl" "public_acl" {
  bucket = aws_s3_bucket.public_data.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "no_block" {
  bucket                  = aws_s3_bucket.public_data.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ── 2. WILDCARD IAM ROLE ─────────────────────────────────
# The known Trivy weak spot — wildcard action + resource
resource "aws_iam_role" "admin_everything" {
  name = "god-mode-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "wildcard_policy" {
  name = "wildcard-all-access"
  role = aws_iam_role.admin_everything.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "*"
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

# ── 3. OPEN CIDR INGRESS ─────────────────────────────────
# Trivy should flag: SSH open to the world
resource "aws_security_group" "wide_open" {
  name        = "allow-everything"
  description = "Insecure SG for testing"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All traffic from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
