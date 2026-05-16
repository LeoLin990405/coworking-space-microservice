# Kubernetes and Database Deployment Notes

The production deployment assumes an existing EKS cluster with the CloudWatch Container Insights add-on enabled.

## PostgreSQL

Install PostgreSQL with the Bitnami Helm chart:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install coworking bitnami/postgresql
```

Seed the database:

```bash
./scripts/seed-db.sh
```

The app is configured to connect to:

```text
coworking-postgresql.default.svc.cluster.local:5432
```

## Application

After the Docker image is built and pushed to ECR:

```bash
kubectl apply -f deployment/configmap.yaml
kubectl create secret generic coworking-secret \
  --from-literal=DB_PASSWORD="$(kubectl get secret --namespace default coworking-postgresql -o jsonpath='{.data.postgres-password}' | base64 -d)" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f deployment/coworking.yaml
kubectl rollout status deployment/coworking
```

## Verification Commands

```bash
kubectl get svc
kubectl get pods
kubectl describe svc coworking-postgresql
kubectl describe deployment coworking
```

## Endpoints

```bash
curl http://<LOAD_BALANCER_HOST>:5153/health_check
curl http://<LOAD_BALANCER_HOST>:5153/api/reports/daily_usage
curl http://<LOAD_BALANCER_HOST>:5153/api/reports/user_visits
```
