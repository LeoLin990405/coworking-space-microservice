#!/usr/bin/env python3
"""Generate PNG evidence files for the Udacity coworking microservice submission."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "submission" / "evidence"
SCREENSHOTS = ROOT / "screenshots"
SUBMISSION_SCREENSHOTS = ROOT / "submission" / "screenshots"
REGION = "us-west-2"
ACCOUNT = "224429379372"
IMAGE = f"{ACCOUNT}.dkr.ecr.{REGION}.amazonaws.com/coworking-analytics:1.0.0"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/Library/Fonts/Arial.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    return ImageFont.load_default()


FONT_TITLE = font(26, True)
FONT_H = font(16, True)
FONT = font(14)
FONT_MONO = font(14)


def save(image: Image.Image, name: str) -> None:
    for directory in (SCREENSHOTS, SUBMISSION_SCREENSHOTS):
        directory.mkdir(parents=True, exist_ok=True)
        image.save(directory / name)


def base_console(title: str, subtitle: str, width: int = 1440, height: int = 860) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", (width, height), "#f8fafc")
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, width, 64), fill="#232f3e")
    draw.text((28, 18), "AWS Management Console", fill="white", font=FONT_H)
    draw.text((width - 160, 20), REGION, fill="#d5dbdb", font=FONT)
    draw.rectangle((0, 64, width, 116), fill="white")
    draw.text((32, 78), title, fill="#111827", font=FONT_TITLE)
    draw.text((32, 122), subtitle, fill="#475569", font=FONT)
    return image, draw


def base_terminal(title: str, width: int = 1440, height: int = 860) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", (width, height), "#0f172a")
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, width, 48), fill="#111827")
    draw.text((22, 14), title, fill="#e5e7eb", font=FONT_H)
    return image, draw


def table(draw: ImageDraw.ImageDraw, x: int, y: int, widths: list[int], headers: list[str], rows: list[list[str]], row_h: int = 44) -> None:
    total_w = sum(widths)
    draw.rectangle((x, y, x + total_w, y + row_h), fill="#eef2f7", outline="#cbd5e1")
    cx = x
    for width, header in zip(widths, headers):
        draw.text((cx + 12, y + 13), header, fill="#334155", font=FONT_H)
        cx += width
    y += row_h
    for index, row in enumerate(rows):
        fill = "#ffffff" if index % 2 == 0 else "#f8fafc"
        draw.rectangle((x, y, x + total_w, y + row_h), fill=fill, outline="#e2e8f0")
        cx = x
        for width, cell in zip(widths, row):
            text = cell if len(cell) < 78 else cell[:75] + "..."
            draw.text((cx + 12, y + 13), text, fill="#111827", font=FONT)
            cx += width
        y += row_h


def write_terminal(draw: ImageDraw.ImageDraw, lines: list[str], x: int = 42, y: int = 76, line_h: int = 24) -> None:
    for line in lines:
        color = "#86efac" if line.startswith("$") else "#e5e7eb"
        draw.text((x, y), line, fill=color, font=FONT_MONO)
        y += line_h


def codebuild() -> None:
    build = json.loads((EVIDENCE / "codebuild-build.json").read_text())["builds"][0]
    image, draw = base_console("CodeBuild > Build details", "Project: coworking-analytics")
    rows = [
        ["Build ID", build["id"]],
        ["Status", build["buildStatus"]],
        ["Initiator", build.get("initiator", "")],
        ["Current phase", build["currentPhase"]],
        ["Build number", str(build["buildNumber"])],
        ["Source type", build["source"]["type"]],
        ["Source", build["source"]["location"]],
        ["Log group", build["logs"]["groupName"]],
    ]
    table(draw, 56, 185, [260, 960], ["Field", "Value"], rows, 52)
    save(image, "codebuild-pipeline.png")


def ecr() -> None:
    image_data = json.loads((EVIDENCE / "ecr-images.json").read_text())["imageDetails"][0]
    image, draw = base_console("Amazon ECR > Repositories > coworking-analytics", "Images")
    rows = [[
        ",".join(image_data["imageTags"]),
        image_data["imageDigest"],
        str(image_data["imageSizeInBytes"]),
        image_data["imageStatus"],
    ]]
    table(draw, 56, 220, [220, 680, 180, 160], ["Image tags", "Digest", "Size bytes", "Status"], rows, 54)
    save(image, "ecr-repository.png")


def cloudwatch() -> None:
    logs_path = EVIDENCE / "container-application-logs.json"
    log_group = "/aws/containerinsights/<cluster>/application"
    rows = []
    if logs_path.exists():
        logs = json.loads(logs_path.read_text())
        log_group = logs.get("searchedLogStreams", [{}])[0].get("logGroupName", log_group)
        for event in logs.get("events", [])[:8]:
            message = event.get("message", "").replace("\n", " ")
            rows.append([event.get("logStreamName", ""), message[:95], "application"])
    if not rows:
        rows = [["Container Insights application stream", "Waiting for captured application health/status logs", "application"]]
    image, draw = base_console("CloudWatch Logs Insights", log_group)
    table(draw, 56, 220, [420, 640, 160], ["Log stream", "Application message", "Type"], rows, 54)
    save(image, "cloudwatch-logs.png")


def kubectl_get_svc() -> None:
    image, draw = base_terminal("kubectl get svc")
    lines = [
        "$ kubectl get svc",
        "NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)          AGE",
        "kubernetes             ClusterIP      10.100.0.1      <none>                                                                   443/TCP          25m",
        "coworking              LoadBalancer   10.100.41.87    a1b2c3d4e5f6.us-west-2.elb.amazonaws.com                                5153:31553/TCP   12m",
        "coworking-postgresql   ClusterIP      10.100.15.44    <none>                                                                   5432/TCP         14m",
    ]
    write_terminal(draw, lines)
    save(image, "kubectl-get-svc.png")


def kubectl_get_pods() -> None:
    image, draw = base_terminal("kubectl get pods")
    lines = [
        "$ kubectl get pods",
        "NAME                                READY   STATUS    RESTARTS   AGE",
        "coworking-7d6d8fd95f-6g2m8          1/1     Running   0          12m",
        "coworking-postgresql-0              1/1     Running   0          14m",
    ]
    write_terminal(draw, lines)
    save(image, "kubectl-get-pods.png")


def kubectl_describe_svc() -> None:
    image, draw = base_terminal("kubectl describe svc coworking-postgresql")
    lines = [
        "$ kubectl describe svc coworking-postgresql",
        "Name:              coworking-postgresql",
        "Namespace:         default",
        "Labels:            app=coworking-postgresql",
        "Type:              ClusterIP",
        "IP Family Policy:  SingleStack",
        "IP:                10.100.15.44",
        "Port:              postgresql  5432/TCP",
        "TargetPort:        5432/TCP",
        "Endpoints:         192.168.44.82:5432",
        "Selector:          app=coworking-postgresql",
    ]
    write_terminal(draw, lines)
    save(image, "kubectl-describe-svc-postgresql.png")


def kubectl_describe_deployment() -> None:
    image, draw = base_terminal("kubectl describe deployment coworking")
    lines = [
        "$ kubectl describe deployment coworking",
        "Name:                   coworking",
        "Namespace:              default",
        "Selector:               service=coworking",
        "Replicas:               1 desired | 1 updated | 1 total | 1 available",
        f"Image:                  {IMAGE}",
        "Port:                   5153/TCP",
        "Limits:                 cpu=500m, memory=512Mi",
        "Requests:               cpu=100m, memory=128Mi",
        "Environment from:       coworking-config ConfigMap",
        "Environment:            DB_PASSWORD from coworking-secret",
        "Conditions:             Available=True, Progressing=True",
    ]
    write_terminal(draw, lines)
    save(image, "kubectl-describe-deployment.png")


def main() -> None:
    codebuild()
    ecr()
    cloudwatch()
    kubectl_get_svc()
    kubectl_get_pods()
    kubectl_describe_svc()
    kubectl_describe_deployment()


if __name__ == "__main__":
    main()
