ARG BASE_IMAGE_VERSION=latest

FROM postgres:${BASE_IMAGE_VERSION}

COPY script.sh /usr/local/bin/backup.sh
RUN apt-get update && apt-get install -y gzip && rm -rf /var/lib/apt/lists/*
RUN chmod +x /usr/local/bin/backup.sh

VOLUME [ "/backup" ]

ENTRYPOINT ["/usr/local/bin/backup.sh"]