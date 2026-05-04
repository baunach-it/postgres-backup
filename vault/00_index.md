---
type: index
repo: postgres-backup
workspace: baunach-postgres
tenant: baunach
---

# postgres-backup Repo-Vault

Image-spezifische Doku fuer `postgres-backup` (logisches Backup, pg_dump → S3-optional).

## Inhalt

- `concepts/funktionsweise.md` — Ablauf: pg_dump → dos2unix → gzip → S3-Upload
- `decisions/` — Image-spezifische Entscheidungen (TBD)
- `playbooks/` — Image-spezifische Prozeduren (TBD)
- `troubleshooting/` — Fehlerbilder bei Backup-Erstellung / S3-Upload

## Cross-Image-Themen → Workspace-Vault

Liegt unter `~/Workspaces/baunach-postgres/vault/`:

- Praefix-Pattern fuer Env-Vars: `concepts/env-var-prefix-pattern.md`
- pg_dump vs. WAL-G: `concepts/pg-dump-vs-wal-g.md`
- Image-Konventionen (Tags, Architekturen, CI): `stack/image-konventionen.md`
- Env-Var-Tabellen aller Images: `stack/env-var-konventionen.md`
- Project-MOC: `projects/postgres-backup.md`

## Doku-Output

`baunach-bis/docs` bzw. `baunach-postgres/docs` (Tenant-shared Klon):
`docs/src/content/docs/projekte/docker-images/Postgres-Backup/`
