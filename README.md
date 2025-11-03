# Docker Image to Backup Postgres databases
This image is based on a standard postgres image and supports pushing dumps to S3 compatible storage using the aws cli.

The aws cli will be automatically installed when the env vars `AWS_S3_BUCKET` and `AWS_S3_PATH` are set.

## Usage
Create a .env file in the desired location
```bash
POSTGRES_BACKUP_SOURCE_DB_HOST=localhost
POSTGRES_BACKUP_SOURCE_DB_PORT=5432
POSTGRES_BACKUP_SOURCE_USER=postgres
POSTGRES_BACKUP_SOURCE_PASSWORD=mypassword
POSTGRES_BACKUP_SOURCE_DB_NAME=source_db

//if s3 should be used, add these vars:
POSTGRES_BACKUP_AWS_ACCESS_KEY_ID=
POSTGRES_BACKUP_AWS_SECRET_ACCESS_KEY=
POSTGRES_BACKUP_AWS_DEFAULT_REGION=
POSTGRES_BACKUP_AWS_S3_BUCKET=
POSTGRES_BACKUP_AWS_S3_PATH=
```
then reference the .env file when running the container and use the `latest` postgres version or use a specific one like `18.0`
```bash
docker run --rm --env-file .env -v /desired/backup/path:/backup --network desired-network baunach/postgres-backup:latest
```