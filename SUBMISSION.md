# Operationalizing a Co-working Space Service - Resubmission

## Repository

- Public GitHub repository: https://github.com/LeoLin990405/coworking-space-microservice

## Container Image

- ECR repository: `coworking-analytics`
- Image URI: `224429379372.dkr.ecr.us-west-2.amazonaws.com/coworking-analytics:1.0.0`
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
| Kubernetes config files | `deployment/configmap.yaml`, `deployment/secrets.yaml`, `deployment/postgresql.yaml`, `deployment/coworking.yaml` |
| Deployment instructions | `README.md`, `kubernetes.md` |

The same screenshots are mirrored under `submission/screenshots/`.

## Local Evidence JSON

AWS evidence captured during the successful build and push is stored under `submission/evidence/`.

- `codebuild-build.json`
- `codebuild-project.json`
- `ecr-repository.json`
- `ecr-images.json`

## Notes

This resubmission updates the CodeBuild project setup to use the GitHub repository as the source and creates a push webhook so the reviewer can verify a `GitHub-Hookshot` automatic build. It also adds explicit Kubernetes Secret manifests in `deployment/secrets.yaml` and requires CloudWatch evidence from Container Insights application logs rather than CodeBuild logs.
