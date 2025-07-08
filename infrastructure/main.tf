provider "aws" {
  region = "ap-south-1" # Free tier supported region
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
}

# 3. Glue ETL Job
resource "aws_glue_job" "music_etl" {
  name     = "music-etl-${var.your_initials}"
  role_arn = aws_iam_role.glue_execution_role.arn  # <-- CRITICAL MISSING LINE
  command {
    script_location = "s3://${aws_s3_bucket.music_data.id}/src/glue_etl.py"
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
