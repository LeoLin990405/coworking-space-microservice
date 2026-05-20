# Coworking Space Service

This repository contains a completed deployment solution for Udacity's **Coworking Space Service** microservice project in course `cd12355`.

The service is a Flask analytics API that reads coworking space activity from PostgreSQL and exposes report endpoints. The solution containerizes the service, builds it with AWS CodeBuild, stores images in Amazon ECR, and deploys it to Kubernetes.

## Architecture

- **Flask API** in `analytics/`.
- **PostgreSQL** deployed in Kubernetes with the provided `StatefulSet` and `ClusterIP` Service manifest.
- **Docker** image built from `analytics/Dockerfile`.
- **AWS CodeBuild** builds the image remotely and pushes semantic version `1.0.0` to ECR.
- **Amazon ECR** stores `coworking-analytics:1.0.0` and `latest`.
- **Kubernetes** runs the service with a `LoadBalancer` service, liveness/readiness probes, ConfigMap, Secret, and CPU/memory requests.
- **AWS CloudWatch** receives EKS/container logs when Container Insights is enabled.

## Important Files

```text
analytics/Dockerfile              Python container image definition
buildspec.yml                     AWS CodeBuild build and ECR push pipeline
deployment/configmap.yaml         Kubernetes ConfigMap and Secret template
deployment/postgresql.yaml        Kubernetes PostgreSQL Secret, Service, and StatefulSet
deployment/coworking.yaml         Kubernetes Service and Deployment
deployment-local/                 Local Kubernetes variants
scripts/deploy-codebuild.sh       Creates ECR, S3 source package, IAM role, CodeBuild project, and starts a build
scripts/wait-codebuild.sh         Polls CodeBuild until completion
scripts/deploy-k8s.sh             Applies PostgreSQL and application Kubernetes manifests
scripts/seed-db.sh                Seeds PostgreSQL with provided SQL files
cloudformation/codebuild-role.yml IAM role for CodeBuild
screenshots/                      Required Udacity submission screenshots
SUBMISSION.md                     Rubric-to-evidence mapping for reviewers
```

## Build and Push Image

```bash
export AWS_REGION=us-west-2
./scripts/deploy-codebuild.sh
./scripts/wait-codebuild.sh <BUILD_ID_FROM_PREVIOUS_COMMAND>
```

The build pushes:

```text
835207447818.dkr.ecr.us-west-2.amazonaws.com/coworking-analytics:1.0.0
835207447818.dkr.ecr.us-west-2.amazonaws.com/coworking-analytics:latest
```

## Deploy to Kubernetes

Use an EKS cluster with `kubectl` configured locally:

```bash
./scripts/deploy-k8s.sh
./scripts/seed-db.sh
```

The deployment creates:

- `coworking-postgresql` PostgreSQL StatefulSet.
- `coworking-postgresql` ClusterIP Service.
- `coworking-config` ConfigMap.
- `coworking-secret` Secret.
- `coworking` Deployment.
- `coworking` LoadBalancer Service.

## API Verification

```bash
curl http://<LOAD_BALANCER_HOST>:5153/health_check
curl http://<LOAD_BALANCER_HOST>:5153/api/reports/daily_usage
curl http://<LOAD_BALANCER_HOST>:5153/api/reports/user_visits
```

## Resource Choices

The application is lightweight Flask API code, so the Kubernetes manifest requests `100m` CPU and `128Mi` memory and limits each pod to `500m` CPU and `512Mi` memory. For an EKS worker node, `t3.small` is sufficient for development, while `t3.medium` is a safer baseline for a small production cluster because it leaves headroom for Kubernetes system pods, PostgreSQL, logging agents, and rolling deployments.

## Cost Notes

To reduce costs, run the smallest EKS node group that satisfies memory requirements, set Kubernetes resource requests realistically, and delete unused LoadBalancers/ECR images/CodeBuild projects. In a production environment, move PostgreSQL to a managed RDS instance only when operational requirements justify the cost; for this project submission, a Kubernetes PostgreSQL StatefulSet keeps the deployment self-contained.

## Submission Evidence

Evidence files from the AWS build are stored in `submission/evidence/`. Required screenshots are stored in both `screenshots/` and `submission/screenshots/`:

- `codebuild-pipeline.png`
- `ecr-repository.png`
- `kubectl-get-svc.png`
- `kubectl-get-pods.png`
- `kubectl-describe-svc-postgresql.png`
- `kubectl-describe-deployment.png`
- `cloudwatch-logs.png`
