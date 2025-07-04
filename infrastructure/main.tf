provider "aws" {
  region = "ap-south-1" # Free tier supported region
}

# S3 Data Lake
resource "aws_s3_bucket" "music_data" {
  bucket = "music-data-${var.your_initials}" # Change your_initials
  acl    = "private"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "music_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda Function
resource "aws_lambda_function" "data_generator" {
  function_name = "music_data_generator"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.8"
  s3_bucket     = aws_s3_bucket.music_data.id
  s3_key        = "src/data_generator.zip"
}

# Glue Job
resource "aws_glue_job" "music_etl" {
  name     = "music_data_transformation"
  role_arn = aws_iam_role.glue_role.arn
  command {
    script_location = "s3://${aws_s3_bucket.music_data.bucket}/src/glue_etl.py"
  }
}