provider "aws" {
  region = "ap-south-1"
}

# ========== IAM ROLES ==========

# Lambda Role
resource "aws_iam_role" "lambda_generator_role" {
  name = "lambda-role-${var.your_initials}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Glue Role
resource "aws_iam_role" "glue_execution_role" {
  name = "glue-role-${var.your_initials}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

# Lambda Policy Attachment
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_generator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Step Functions Role
resource "aws_iam_role" "step_functions_role" {
  name = "step-functions-role-${var.your_initials}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      },
      Action: "sts:AssumeRole"
    }]
  })
}

# Step Functions Policy Attachment
resource "aws_iam_role_policy_attachment" "step_functions_execution" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
}

# ========== S3 BUCKET + LAMBDA CODE ==========

resource "aws_s3_bucket" "music_data" {
  bucket = "music-data-${var.your_initials}"
}

resource "aws_s3_object" "data_generator_code" {
  bucket = aws_s3_bucket.music_data.id
  key    = "src/data_generator.zip"
  source = "../src/data_generator/data_generator.zip"
}

# ========== LAMBDA FUNCTION ==========

resource "aws_lambda_function" "data_generator" {
  function_name = "music-data-generator-${var.your_initials}"
  role          = aws_iam_role.lambda_generator_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.8"
  timeout       = 10
  s3_bucket     = aws_s3_bucket.music_data.id
  s3_key        = "src/data_generator.zip"

  depends_on = [
    aws_iam_role.lambda_generator_role,
    aws_s3_object.data_generator_code
  ]
}

# ========== GLUE JOB ==========

resource "aws_glue_job" "music_etl" {
  name     = "music-etl-${var.your_initials}"
  role_arn = aws_iam_role.glue_execution_role.arn
  glue_version = "3.0"

  command {
    script_location = "s3://${aws_s3_bucket.music_data.id}/src/glue_etl.py"
    python_version  = "3"
  }
}

# ========== STEP FUNCTIONS ==========

resource "aws_sfn_state_machine" "pipeline" {
  name     = "music-pipeline-${var.your_initials}"
  role_arn = aws_iam_role.step_functions_role.arn

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
      "Parameters": {
        "JobName": "${aws_glue_job.music_etl.name}"
      },
      "End": true
    }
  }
}
EOF
}
