# Kubernetes and Database Deployment Notes

The production deployment assumes an existing EKS cluster with the CloudWatch Container Insights add-on enabled.

## PostgreSQL

Create the PostgreSQL password Secret and deploy PostgreSQL with the included manifest:

```bash
export POSTGRES_PASSWORD='<choose-a-password>'
kubectl create secret generic coworking-postgresql \
  --from-literal=postgres-password="$POSTGRES_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f deployment/postgresql.yaml
kubectl rollout status statefulset/coworking-postgresql
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
  --from-literal=DB_PASSWORD="$POSTGRES_PASSWORD" \
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
