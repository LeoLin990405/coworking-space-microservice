# Submission Notes

## Completed Evidence

- CodeBuild project evidence: `submission/evidence/codebuild-project.json`
- CodeBuild successful build evidence: `submission/evidence/codebuild-build.json`
- ECR repository evidence: `submission/evidence/ecr-repository.json`
- ECR pushed image evidence: `submission/evidence/ecr-images.json`

The successful image tag is:

```text
835207447818.dkr.ecr.us-west-2.amazonaws.com/coworking-analytics:1.0.0
```

## Kubernetes Verification Commands

After applying the manifests to an EKS cluster, capture the required screenshots with:

```bash
kubectl get svc
kubectl get pods
kubectl describe svc coworking-service
kubectl describe deployment coworking-analytics
kubectl logs deployment/coworking-analytics
```

CloudWatch evidence for the CodeBuild pipeline is available in log group:

```text
/aws/codebuild/coworking-analytics
```
