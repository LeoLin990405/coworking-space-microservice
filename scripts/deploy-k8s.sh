#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-coworking}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"

kubectl create secret generic coworking-postgresql \
  --from-literal=postgres-password="$POSTGRES_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f deployment/postgresql.yaml
kubectl apply -f deployment/configmap.yaml
kubectl create secret generic coworking-secret --from-literal=DB_PASSWORD="$POSTGRES_PASSWORD" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f deployment/coworking.yaml
kubectl rollout status statefulset/coworking-postgresql
kubectl rollout status deployment/"$SERVICE_NAME"
