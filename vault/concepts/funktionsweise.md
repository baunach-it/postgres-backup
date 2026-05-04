---
type: concept
repo: postgres-backup
status: active
tags: [pg_dump, gzip, s3, backup]
---

# Funktionsweise — postgres-backup

Logisches Backup einer PostgreSQL-Datenbank, optional mit S3-Upload.

## Ablauf

1. **`pg_dump`** erstellt SQL-Dump der Quell-Datenbank.
2. **`dos2unix`** normalisiert Zeilenumbrueche (Windows-Kompatibilitaet beim spaeteren Restore).
3. **`gzip`** komprimiert den Dump.
4. Datei wird unter `/backup` abgelegt: `{TIMESTAMP}_dump_{HOST}_{DBNAME}.sql.gz`.
5. Wenn S3-Env-Vars gesetzt sind: AWS CLI wird zur Laufzeit installiert (nicht im Image vorhanden)
   und der Dump nach S3 hochgeladen.

## Lazy-Install der AWS CLI

Die AWS CLI ist bewusst **nicht** Teil des Image-Layers — sie wird nur installiert, wenn
S3-Env-Vars gesetzt sind. Damit bleibt das Image kleiner und Setups ohne S3-Upload booten
schneller.

## Quell-DB (Pflicht)

`POSTGRES_BACKUP_SOURCE_DB_HOST`, `_DB_PORT`, `_USER`, `_PASSWORD`, `_DB_NAME`

## S3-Upload (optional)

`POSTGRES_BACKUP_AWS_ACCESS_KEY_ID`, `_AWS_SECRET_ACCESS_KEY`, `_AWS_DEFAULT_REGION`,
`_AWS_S3_BUCKET`, `_AWS_S3_PATH`, `_S3_ENDPOINT`, `_AWS_CLI_VERSION`

`_S3_ENDPOINT` schaltet auf Custom-S3 (Hetzner Object Storage, MinIO, ...).

## Volume

`/backup` — lokaler Backup-Speicher. Retention/Rotation ausserhalb des Images
(Cronjob auf dem Host oder Sidecar).

## Bezug

- Workspace-Vault: `concepts/pg-dump-vs-wal-g.md`, `stack/env-var-konventionen.md`
- Doku-Output: `docs/src/content/docs/projekte/docker-images/Postgres-Backup/uebersicht.md`
