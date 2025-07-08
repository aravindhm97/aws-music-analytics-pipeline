provider "aws" {
  region = "ap-south-1" # Free tier supported region
}

# IAM ROLES (MUST EXIST BEFORE LAMBDA/GLUE)
resource "aws_iam_role" "lambda_generator_role" {
  name = "lambda-role-${var.your_initials}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "glue_execution_role" {
  name = "glue-role-${var.your_initials}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

# Attach basic execution policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_generator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create S3 bucket object for Lambda code
resource "aws_s3_object" "data_generator_code" {
  bucket = aws_s3_bucket.music_data.id
  key    = "src/data_generator.zip"
  source = "../src/data_generator/data_generator.zip"  # Path to your ZIP file
}

# 1. S3 Data Lake
resource "aws_s3_bucket" "music_data" {
  bucket = "music-data-${var.your_initials}" # e.g., music-data-akm
}

# 2. Lambda Functions
resource "aws_lambda_function" "data_generator" {
  function_name = "music-data-generator-${var.your_initials}"
  role          = aws_iam_role.lambda_generator_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.8"
  timeout       = 10
  s3_bucket     = aws_s3_bucket.music_data.id
  s3_key        = "src/data_generator.zip"

  depends_on = [
    aws_iam_role.lambda_generator_role,  # Ensures role exists first
    aws_s3_object.data_generator_code
  ]
}

# 3. Glue ETL Job
resource "aws_glue_job" "music_etl" {
  name     = "music-etl-${var.your_initials}"
  role_arn = aws_iam_role.glue_execution_role.arn
  glue_version = "3.0"

  command {
    script_location = "s3://${aws_s3_bucket.music_data.id}/src/glue_etl.py"
    python_version  = "3"
  }
}

# 4. Step Functions Orchestration
resource "aws_sfn_state_machine" "pipeline" {
  definition = <<EOF
{
  "StartAt": "GenerateData",
  "States": {
    "GenerateData": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.data_generator.arn}",
      "Next": "RunETL"
    },
    "RunETL": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun",
      "Parameters": {"JobName": "${aws_glue_job.etl_job.name}"},
      "End": true
    }
  }
}
EOF
}
