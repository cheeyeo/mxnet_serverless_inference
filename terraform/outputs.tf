output "input_bucket" {
  description = "S3 Name of input bucket"
  value       = aws_s3_bucket.input_bucket.id
}

output "resource_bucket" {
  description = "S3 Name of resource bucket"
  value       = aws_s3_bucket.resource_bucket.id
}

output "output_bucket" {
  description = "S3 Name of output bucket"
  value       = aws_s3_bucket.output_bucket.id
}

output "lambda_fn" {
  description = "ARN of Lambda function"
  value       = aws_lambda_function.mxnet_infer_lambda.arn
}

output "lambda_invoke_arn" {
	description = "Invoke ARN of Lambda function for local testing"
	value = aws_lambda_function.mxnet_infer_lambda.invoke_arn
}

output "aws_profile" {
	description = "AWS Profile in use"
	value = var.aws_profile
}