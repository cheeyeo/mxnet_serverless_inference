terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_iam_role" "mxnet" {
  name = "MXNetLambdaRole22"

  description = "IAM role for lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "MXNetLambda"
  }
}


resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.mxnet.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_access" {
  role       = aws_iam_role.mxnet.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  role       = aws_iam_role.mxnet.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "mxnet-lambda-input"
  acl    = "private"
  tags = {
    Project = "mxnetinfernece"
  }
}

resource "aws_s3_bucket" "resource_bucket" {
  bucket = "mxnet-lambda-resource"
  acl    = "private"
  tags = {
    Project = "mxnetinfernece"
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "mxnet-lambda-output"
  acl    = "private"
  tags = {
    Project = "mxnetinfernece"
  }
}


resource "aws_lambda_function" "mxnet_infer_lambda" {
  function_name = "mxnet_infer_lambda"
  role          = aws_iam_role.mxnet.arn
  image_uri     = var.image_repo
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  package_type  = "Image"
  environment {
    variables = {
      OUTPUT_BUCKET   = aws_s3_bucket.output_bucket.id
      RESOURCE_BUCKET = aws_s3_bucket.resource_bucket.id
    }
  }
}

# Add events to lambda to listen for changes in input bucket...
# This is added under Events for the S3 bucket and not via event bus...
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mxnet_infer_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.mxnet_infer_lambda.arn

    events = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}