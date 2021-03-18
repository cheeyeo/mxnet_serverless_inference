variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS Profile to use"
  type        = string
  default     = ""
}

variable "image_repo" {
  description = "ECR Image repo for container to run in lambda"
  type        = string
  default     = ""
}

variable "lambda_memory_size" {
  description = "Memory for lambda function"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Timeout for lambda function"
  type        = number
  default     = 3
}