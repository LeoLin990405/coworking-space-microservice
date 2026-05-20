#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-coworking}"

kubectl apply -f deployment/secrets.yaml
kubectl apply -f deployment/postgresql.yaml
kubectl apply -f deployment/configmap.yaml
kubectl apply -f deployment/coworking.yaml
kubectl rollout status statefulset/coworking-postgresql
kubectl rollout status deployment/"$SERVICE_NAME"
