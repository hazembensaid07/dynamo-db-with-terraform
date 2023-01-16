provider "aws" {
  alias      = "eu-west-2"
  region     = var.region1
  access_key = var.ACESSKEY
  secret_key = var.SECRETKEY
}

provider "aws" {
  alias      = "us-east-1"
  region     = var.region2
  access_key = var.ACESSKEY
  secret_key = var.SECRETKEY
}


resource "aws_dynamodb_table" "primary-table" {
  provider = aws.eu-west-2
  #primary key 
  hash_key = "id"
  #  billing_mode="PAY_PER_REQUEST" // to use dynamodb on demand default set to provisioned
  name = var.name
  #enable dynamoDB stream
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 1
  write_capacity   = 1

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true

  }
}

resource "aws_dynamodb_table" "secondary-table" {
  provider = aws.us-east-1

  hash_key         = "id"
  name             = var.name
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 1
  write_capacity   = 1

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true

  }
}

resource "aws_dynamodb_global_table" "myTable" {
  depends_on = [
    aws_dynamodb_table.primary-table,
    aws_dynamodb_table.secondary-table,
  ]
  provider = aws.eu-west-2

  name = var.name

  replica {
    region_name = "eu-west-2"
  }

  replica {
    region_name = "us-east-1"
  }
}


{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:GenerateDataKey",
                "kms:ReEncryptFrom",
                "kms:ReEncryptTo",
                "kms:DescribeKey"
            ],
            "Resource": [
                "arn:aws:kms:REGION:ACCOUNT_ID:key/KEY_ID"
            ]
        }
    ]
}
