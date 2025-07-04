## Cloud Music Analytics Pipeline
```mermaid
graph LR
A[Lambda Data Generator] -->|Writes JSON| B[S3 Raw Zone]
B --> C[Glue ETL Job]
C -->|Outputs Parquet| D[S3 Processed Zone]
D --> E[Athena Queries]
F[Terraform] -->|Creates| A
F -->|Creates| C
G[Cleanup Lambda] -->|Optimizes Costs| B