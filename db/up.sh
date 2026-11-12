#!/usr/bin/env bash
# Starts SQL Server in Docker (once), creates the database and loads db/ into it (once). Safe to run again.
set -euo pipefail
cd "$(dirname "$0")/.."

NAME=${DB_CONTAINER:-cdi-sample-sql}
PORT=${DB_PORT:-1433}
DBNAME=${DB_NAME:-myTestDB}
VOLUME=${DB_VOLUME:-cdi_sample_sql_data}
IMAGE=mcr.microsoft.com/mssql/server:2022-latest
die() { echo "ERROR: $*" >&2; exit 1; }

command -v docker >/dev/null || die "Docker is not installed. Install Docker Desktop (https://www.docker.com/products/docker-desktop/), start it, and run this again."
docker info >/dev/null 2>&1 || die "Docker is installed but not running. Start Docker Desktop and run this again."

# The sa password is generated once, kept in .local/ (git-ignored) and never printed to the repo.
mkdir -p .local
if [ ! -s .local/sa-password ]; then
  ( umask 077; echo "Aa1-$(openssl rand -hex 12)" > .local/sa-password )
fi
PW=$(cat .local/sa-password)

if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  docker ps --format '{{.Names}}' | grep -qx "$NAME" || { echo "Starting existing container $NAME"; docker start "$NAME" >/dev/null; }
else
  echo "Creating SQL Server container $NAME (first run downloads the image; on Apple Silicon it runs emulated)"
  docker run --platform linux/amd64 -d --name "$NAME" -e ACCEPT_EULA=Y -e "MSSQL_SA_PASSWORD=$PW" \
    -p "$PORT:1433" -v "$VOLUME:/var/opt/mssql" "$IMAGE" >/dev/null
fi

sql() { docker exec -i -e "SQLCMDPASSWORD=$PW" "$NAME" /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -C -b "$@"; }

echo -n "Waiting for SQL Server"
for i in $(seq 1 90); do
  if sql -Q "SELECT 1" >/dev/null 2>&1; then break; fi
  echo -n "."; sleep 2
  [ "$i" = 90 ] && die "SQL Server did not become ready (docker logs $NAME). If you deleted .local/sa-password, run: make db-reset"
done
echo " ready"

if [ "$(sql -h -1 -W -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = '$DBNAME'" | tr -d '[:space:]')" = "0" ]; then
  echo "Creating database $DBNAME and loading db/"
  sql -Q "CREATE DATABASE [$DBNAME]"
  for f in db/synthetic/tables/*.sql db/synthetic/procedures/*.sql db/synthetic/views/*.sql db/seed.sql; do
    echo "  $f"; sql -d "$DBNAME" < "$f"
  done
else
  echo "Database $DBNAME already exists (make db-reset to rebuild it)"
fi
echo "Database ready: localhost,$PORT  database $DBNAME  user sa  (password in .local/sa-password)"
