#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${SERVICE_NAME:-coworking}"
HELM_REPO_NAME="${HELM_REPO_NAME:-bitnami}"
POSTGRES_RELEASE="${POSTGRES_RELEASE:-coworking}"

helm repo add "$HELM_REPO_NAME" https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install "$POSTGRES_RELEASE" "$HELM_REPO_NAME/postgresql"

POSTGRES_PASSWORD=$(kubectl get secret --namespace default "${POSTGRES_RELEASE}-postgresql" -o jsonpath="{.data.postgres-password}" | base64 -d)
kubectl apply -f deployment/configmap.yaml
kubectl create secret generic coworking-secret --from-literal=DB_PASSWORD="$POSTGRES_PASSWORD" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f deployment/coworking.yaml
kubectl rollout status deployment/"$SERVICE_NAME"
