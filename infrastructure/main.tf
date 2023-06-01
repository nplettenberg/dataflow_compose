terraform {
  required_providers {
    minio = {
      version = "0.1.0"
      source  = "refaktory/minio"
    }
  }
}

provider "minio" {
  endpoint = "minio:9000"
  access_key = "${local.envs["MINIO_ROOT_USER"]}"
  secret_key = "${local.envs["MINIO_ROOT_PASSWORD"]}"
  ssl = false
}

resource "minio_bucket" "bucket" {
  name = "secrets"
}

# Create a policy.
resource "minio_canned_policy" "allowReadSecretsPolicy" {
  name = "allowReadSecrets"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::secrets/*"
      ]
    }
  ]
}
EOF
}

# Create a policy.
resource "minio_canned_policy" "allowWriteAndDeleteSecretsPolicy" {
  name = "allowWriteAndDeleteSecrets"
  policy = <<EOF
          {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Action": [
                  "s3:PutObject",
                  "s3:DeleteObject"
                ],
                "Effect": "Allow",
                "Resource": [
                  "arn:aws:s3:::secrets/*"
                ]
              }
            ]
          }
          EOF
}

resource "minio_user" "credentials_user" {
  access_key = "${local.envs["CREDENTIALS_ACCESS_KEY"]}"
  secret_key = "${local.envs["CREDENTIALS_ACCESS_SECRET"]}"
  policies = [
    minio_canned_policy.allowWriteAndDeleteSecretsPolicy.name,
    minio_canned_policy.allowReadSecretsPolicy.name,
  ]
}