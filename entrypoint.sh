#!/bin/bash
set -euo pipefail

trap 'echo "ERROR: command failed (line $LINENO): $BASH_COMMAND" >&2' ERR

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

export AWS_ACCESS_KEY_ID="${POSTGRES_BACKUP_AWS_ACCESS_KEY_ID:-}"
export AWS_SECRET_ACCESS_KEY="${POSTGRES_BACKUP_AWS_SECRET_ACCESS_KEY:-}"
export AWS_DEFAULT_REGION="${POSTGRES_BACKUP_AWS_DEFAULT_REGION:-}"

POSTGRES_BACKUP_SOURCE_DB_HOST="${POSTGRES_BACKUP_SOURCE_DB_HOST:-}"
POSTGRES_BACKUP_SOURCE_DB_PORT="${POSTGRES_BACKUP_SOURCE_DB_PORT:-}"
POSTGRES_BACKUP_SOURCE_USER="${POSTGRES_BACKUP_SOURCE_USER:-}"
POSTGRES_BACKUP_SOURCE_PASSWORD="${POSTGRES_BACKUP_SOURCE_PASSWORD:-}"
POSTGRES_BACKUP_SOURCE_DB_NAME="${POSTGRES_BACKUP_SOURCE_DB_NAME:-}"
POSTGRES_BACKUP_AWS_S3_BUCKET="${POSTGRES_BACKUP_AWS_S3_BUCKET:-}"
POSTGRES_BACKUP_AWS_S3_PATH="${POSTGRES_BACKUP_AWS_S3_PATH:-}"
POSTGRES_BACKUP_AWS_CLI_VERSION="${POSTGRES_BACKUP_AWS_CLI_VERSION:-}"
POSTGRES_BACKUP_S3_ENDPOINT="${POSTGRES_BACKUP_S3_ENDPOINT:-}"
CLI_VERSION_ARG=""

if [ -n "$POSTGRES_BACKUP_AWS_CLI_VERSION" ]; then
  CLI_VERSION_ARG="-${POSTGRES_BACKUP_AWS_CLI_VERSION}"
  echo "AWS CLI version argument set to: $CLI_VERSION_ARG"
else
  echo "POSTGRES_BACKUP_AWS_CLI_VERSION is not set, will use the latest one."
fi

# Install AWS CLI only if not installed and POSTGRES_BACKUP_AWS_S3_* environment variables are set
if ! command -v aws &> /dev/null && [ -n "$POSTGRES_BACKUP_AWS_S3_BUCKET" ] && [ -n "$POSTGRES_BACKUP_AWS_S3_PATH" ]; then
  echo "AWS CLI not found and POSTGRES_BACKUP_AWS_S3_* variables are set. Installing AWS CLI..."
  curl -fsS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64${CLI_VERSION_ARG}.zip" -o "awscliv2.zip" \
    || fail "downloading AWS CLI${CLI_VERSION_ARG} failed"
  unzip -q awscliv2.zip || fail "unpacking AWS CLI failed"
  ./aws/install || fail "installing AWS CLI failed"
  rm -rf awscliv2.zip aws
  echo "AWS CLI installed."
  aws --version
else
  echo "AWS CLI is already installed or POSTGRES_BACKUP_AWS_S3_* variables are not set."
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DUMPFILE="/backup/${TIMESTAMP}_dump_${POSTGRES_BACKUP_SOURCE_DB_HOST}_${POSTGRES_BACKUP_SOURCE_DB_NAME}.sql"
GZIPPED_DUMPFILE="${DUMPFILE}.gz"

# A partial dump must not stay in /backup, it would look like a valid backup
echo "saving pg_dump to $DUMPFILE"
if ! PGPASSWORD="$POSTGRES_BACKUP_SOURCE_PASSWORD" pg_dump -h "$POSTGRES_BACKUP_SOURCE_DB_HOST" -p "$POSTGRES_BACKUP_SOURCE_DB_PORT" -U "$POSTGRES_BACKUP_SOURCE_USER" -d "$POSTGRES_BACKUP_SOURCE_DB_NAME" > "$DUMPFILE"; then
  rm -f "$DUMPFILE"
  fail "pg_dump of $POSTGRES_BACKUP_SOURCE_DB_NAME on $POSTGRES_BACKUP_SOURCE_DB_HOST failed"
fi

if ! dos2unix "$DUMPFILE"; then
  rm -f "$DUMPFILE"
  fail "dos2unix on $DUMPFILE failed"
fi
echo "compressing $DUMPFILE to $GZIPPED_DUMPFILE"
if ! gzip "$DUMPFILE"; then
  rm -f "$DUMPFILE" "$GZIPPED_DUMPFILE"
  fail "compressing $DUMPFILE failed"
fi

# Upload to S3
if [ -n "$POSTGRES_BACKUP_AWS_S3_BUCKET" ] && [ -n "$POSTGRES_BACKUP_AWS_S3_PATH" ]; then
  ENDPOINT_ARGS=()
  if [ -n "$POSTGRES_BACKUP_S3_ENDPOINT" ]; then
    ENDPOINT_ARGS=(--endpoint-url "$POSTGRES_BACKUP_S3_ENDPOINT")
    echo "Using custom S3 endpoint: $POSTGRES_BACKUP_S3_ENDPOINT"
  fi

  # The complete local dump stays in /backup when only the upload fails
  if ! aws s3 cp "$GZIPPED_DUMPFILE" "s3://$POSTGRES_BACKUP_AWS_S3_BUCKET/$POSTGRES_BACKUP_AWS_S3_PATH/" "${ENDPOINT_ARGS[@]}"; then
    fail "uploading $GZIPPED_DUMPFILE to s3://$POSTGRES_BACKUP_AWS_S3_BUCKET/$POSTGRES_BACKUP_AWS_S3_PATH/ failed"
  fi
  echo "Backup successfully uploaded to S3: s3://$POSTGRES_BACKUP_AWS_S3_BUCKET/$POSTGRES_BACKUP_AWS_S3_PATH/"
else
  echo "POSTGRES_BACKUP_AWS_S3_BUCKET or POSTGRES_BACKUP_AWS_S3_PATH is not set. Skipping S3 upload."
fi
