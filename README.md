# AWS Music Analytics Pipeline
> Free Tier Serverless Data Pipeline

[![Terraform](https://img.shields.io/badge/terraform-1.3+-blue.svg)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-Free_Tier-orange.svg)](https://aws.amazon.com/free/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

End-to-end data pipeline demonstrating:
- 🚀 **Infrastructure as Code** with Terraform
- ♻️ **Serverless Architecture** (Lambda + Glue)
- 📊 **ETL Processing** from JSON to Parquet
- 💰 **Cost Optimization** for Free Tier

## Architecture
![System Diagram](docs/ARCHITECTURE.md)

## Key Features
- Generates realistic music streaming data
- Processes 1000+ records/month in Free Tier
- Automated resource cleanup
- Ready for Athena analysis

## Deployment
```bash
# Clone repository
git clone https://github.com/<your-username>/aws-music-analytics-pipeline.git

# Follow full deployment guide:
https://github.com/aravindhm97/aws-music-analytics-pipeline/tree/main/docs/DEPLOYMENT_GUIDE.md
