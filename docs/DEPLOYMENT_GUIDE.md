## AWS Free Tier Deployment

### Prerequisites:
- AWS Account (Free Tier eligible)
- AWS CLI installed
- Terraform installed

### Steps:
1. **Clone repository:**
   ```bash
   git clone https://github.com/<your-username>/aws-music-analytics-pipeline.git

2. Configure AWS credentials:
   ```bash
   aws configure

3. Initialize Terraform:
   ```bash
   cd infrastructure
   # Initialize Terraform project
   terraform init

   # Review changes
   terraform plan

4. Deploy infrastructure:
   ```bash
   terraform apply -var="your_initials=<your-initials>"

5. Upload code to S3:
   ```bash
   aws s3 sync ../src s3://music-data-<your-initials>/src/

6. Trigger Lambda:
   Manually invoke through AWS Console Or schedule with EventBridge

7. Run Glue Job:
   Execute through AWS Console

8. Query data with Athena:
   ```sql
   CREATE EXTERNAL TABLE music_data (
     user_id string,
     song_id int,
     artist string,
     duration_min float
   )
   STORED AS PARQUET
   LOCATION 's3://music-data-<your-initials>/processed_data/';

Destroy Resources (Avoid Costs):
```bash
terraform destroy
