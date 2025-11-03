#!/bin/bash

POSTGRES_BACKUP_SOURCE_DB_HOST=$POSTGRES_BACKUP_SOURCE_DB_HOST
POSTGRES_BACKUP_SOURCE_DB_PORT=$POSTGRES_BACKUP_SOURCE_DB_PORT
POSTGRES_BACKUP_SOURCE_USER=$POSTGRES_BACKUP_SOURCE_USER
POSTGRES_BACKUP_SOURCE_PASSWORD=$POSTGRES_BACKUP_SOURCE_PASSWORD
POSTGRES_BACKUP_SOURCE_DB_NAME=$POSTGRES_BACKUP_SOURCE_DB_NAME
POSTGRES_BACKUP_AWS_S3_BUCKET=$POSTGRES_BACKUP_AWS_S3_BUCKET
POSTGRES_BACKUP_AWS_S3_PATH=$POSTGRES_BACKUP_AWS_S3_PATH

# Install AWS CLI only if not installed and POSTGRES_BACKUP_AWS_S3_* environment variables are set
if ! command -v aws &> /dev/null && [ -n "$POSTGRES_BACKUP_AWS_S3_BUCKET" ] && [ -n "$POSTGRES_BACKUP_AWS_S3_PATH" ]; then
  echo "AWS CLI not found and POSTGRES_BACKUP_AWS_S3_* variables are set. Installing AWS CLI..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf awscliv2.zip aws
  echo "AWS CLI installed."
  aws --version
else
  echo "AWS CLI is already installed or POSTGRES_BACKUP_AWS_S3_* variables are not set."
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DUMPFILE="/backup/${TIMESTAMP}_dump_${POSTGRES_BACKUP_SOURCE_DB_HOST}_${POSTGRES_BACKUP_SOURCE_DB_NAME}_.sql.gz"

echo "saving pg_dump to $DUMPFILE"
PGPASSWORD=$POSTGRES_BACKUP_SOURCE_PASSWORD pg_dump -h $POSTGRES_BACKUP_SOURCE_DB_HOST -p $POSTGRES_BACKUP_SOURCE_DB_PORT -U $POSTGRES_BACKUP_SOURCE_USER -d $POSTGRES_BACKUP_SOURCE_DB_NAME | gzip > "$DUMPFILE"

# Upload to S3
if [ -n "$POSTGRES_BACKUP_AWS_S3_BUCKET" ] && [ -n "$POSTGRES_BACKUP_AWS_S3_PATH" ]; then
  aws s3 cp "$DUMPFILE" "s3://$POSTGRES_BACKUP_AWS_S3_BUCKET/$POSTGRES_BACKUP_AWS_S3_PATH/"
  if [ $? -eq 0 ]; then
    echo "Backup successfully uploaded to S3: s3://$POSTGRES_BACKUP_AWS_S3_BUCKET/$POSTGRES_BACKUP_AWS_S3_PATH/"
  else
    echo "Failed to upload backup to S3"
  fi
else
  echo "POSTGRES_BACKUP_AWS_S3_BUCKET or POSTGRES_BACKUP_AWS_S3_PATH is not set. Skipping S3 upload."
fi