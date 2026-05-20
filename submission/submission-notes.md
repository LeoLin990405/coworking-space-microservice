# Submission Notes

## Completed Evidence

- CodeBuild project evidence: `submission/evidence/codebuild-project.json`
- CodeBuild successful build evidence: `submission/evidence/codebuild-build.json`
- ECR repository evidence: `submission/evidence/ecr-repository.json`
- ECR pushed image evidence: `submission/evidence/ecr-images.json`
- Screenshots are included in `screenshots/` and mirrored in `submission/screenshots/`.

The successful image tag is:

```text
835207447818.dkr.ecr.us-west-2.amazonaws.com/coworking-analytics:1.0.0
```

## Kubernetes Verification Commands

After applying the manifests to an EKS cluster, verify with:

```bash
kubectl get svc
kubectl get pods
kubectl describe svc coworking-postgresql
kubectl describe deployment coworking
kubectl logs deployment/coworking
```

CloudWatch evidence for the CodeBuild pipeline is available in log group:

```text
/aws/codebuild/coworking-analytics
```
