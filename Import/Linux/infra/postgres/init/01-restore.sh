#!/bin/bash
set -e

echo "Restoring custom-format dump into ${POSTGRES_DB}..."

pg_restore \
  --username="${POSTGRES_USER}" \
  --dbname="${POSTGRES_DB}" \
  --no-owner \
  --no-privileges \
  --exit-on-error \
  /docker-entrypoint-initdb.d/dump.pgc

echo "Restore complete."
