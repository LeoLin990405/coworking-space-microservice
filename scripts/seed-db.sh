#!/usr/bin/env bash
set -euo pipefail

POSTGRES_RELEASE="${POSTGRES_RELEASE:-coworking}"
POSTGRES_PASSWORD=$(kubectl get secret --namespace default "${POSTGRES_RELEASE}-postgresql" -o jsonpath="{.data.postgres-password}" | base64 -d)

kubectl port-forward --namespace default "svc/${POSTGRES_RELEASE}-postgresql" 5432:5432 &
PORT_FORWARD_PID=$!
trap 'kill ${PORT_FORWARD_PID}' EXIT
sleep 5

for file in db/1_create_tables.sql db/2_seed_users.sql db/3_seed_tokens.sql; do
  PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < "$file"
done
