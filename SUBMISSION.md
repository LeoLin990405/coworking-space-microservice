# Operationalizing a Co-working Space Service - Resubmission

## Repository

- Public GitHub repository: https://github.com/LeoLin990405/coworking-space-microservice

## Container Image

- ECR repository: `coworking-analytics`
- Image URI: `835207447818.dkr.ecr.us-west-2.amazonaws.com/coworking-analytics:1.0.0`
- Additional tag: `latest`

## Required Udacity Evidence

| Requirement | Evidence file |
| --- | --- |
| Dockerfile for the analytics service | `analytics/Dockerfile` |
| CodeBuild pipeline screenshot | `screenshots/codebuild-pipeline.png` |
| ECR repository/image screenshot | `screenshots/ecr-repository.png` |
| `kubectl get svc` screenshot | `screenshots/kubectl-get-svc.png` |
| `kubectl get pods` screenshot | `screenshots/kubectl-get-pods.png` |
| `kubectl describe svc <DATABASE_SERVICE_NAME>` screenshot | `screenshots/kubectl-describe-svc-postgresql.png` |
| `kubectl describe deployment <SERVICE_NAME>` screenshot | `screenshots/kubectl-describe-deployment.png` |
| CloudWatch logs screenshot | `screenshots/cloudwatch-logs.png` |
| Kubernetes config files | `deployment/configmap.yaml`, `deployment/postgresql.yaml`, `deployment/coworking.yaml` |
| Deployment instructions | `README.md`, `kubernetes.md` |

The same screenshots are mirrored under `submission/screenshots/`.

## Local Evidence JSON

AWS evidence captured during the successful build and push is stored under `submission/evidence/`.

- `codebuild-build.json`
- `codebuild-project.json`
- `ecr-repository.json`
- `ecr-images.json`

## Notes

The Kubernetes manifests include resource requests and limits to support predictable scheduling and avoid unbounded resource usage. The application deployment uses the semantic image tag `1.0.0` instead of relying only on `latest`.
