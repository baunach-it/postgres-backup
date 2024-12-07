# Docker Image to Backup & Restore Postgres databases

## Usage
### without .env file
```
docker run --rm \
  -e SOURCE_DB_HOST="localhost" \
  -e SOURCE_USER="postgres" \
  -e SOURCE_PASSWORD="mypassword" \
  -e SOURCE_DB_NAME="source_db" \ 
  --network desired-network
  -v /desired/backup/path:/backup
  baunach/postgres-backup
```
### with .env file
Create a .env file in the desired location
```bash
SOURCE_DB_HOST=localhost
SOURCE_USER=postgres
SOURCE_PASSWORD=mypassword
SOURCE_DB_NAME=source_db
```
then reference the .env file when running the container
```bash
docker run --rm --env-file .env -v /desired/backup/path:/backup --network desired-network baunach/postgres-backup
```