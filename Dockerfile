ARG BASE_IMAGE_VERSION=latest

FROM postgres:${BASE_IMAGE_VERSION}

ENV POSTGRES_BACKUP_SOURCE_DB_HOST=""
ENV POSTGRES_BACKUP_SOURCE_DB_PORT=""
ENV POSTGRES_BACKUP_SOURCE_USER=""
ENV POSTGRES_BACKUP_SOURCE_PASSWORD=""
ENV POSTGRES_BACKUP_SOURCE_DB_NAME=""
ENV POSTGRES_BACKUP_AWS_ACCESS_KEY_ID=""
ENV POSTGRES_BACKUP_AWS_SECRET_ACCESS_KEY=""
ENV POSTGRES_BACKUP_AWS_DEFAULT_REGION=""
ENV POSTGRES_BACKUP_AWS_S3_BUCKET=""
ENV POSTGRES_BACKUP_AWS_S3_PATH=""

RUN apt-get update && apt-get install -y dos2unix gzip curl unzip && rm -rf /var/lib/apt/lists/*

COPY script.sh /usr/local/bin/backup.sh
RUN dos2unix /usr/local/bin/backup.sh && chmod +x /usr/local/bin/backup.sh

VOLUME [ "/backup" ]

ENTRYPOINT ["/usr/local/bin/backup.sh"]