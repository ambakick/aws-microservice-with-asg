#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request

DEFAULT_ALB_DNS = "microservices-alb-1788265787.us-east-1.elb.amazonaws.com"
DEFAULT_REGION = "us-east-1"


def fetch_json(url: str) -> dict:
    try:
        with urllib.request.urlopen(url, timeout=15) as response:
            body = response.read().decode("utf-8")
        return json.loads(body)
    except urllib.error.URLError as exc:
        raise RuntimeError(f"HTTP request failed for {url}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Non-JSON response from {url}") from exc


def assert_message(url: str, expected_message: str) -> None:
    payload = fetch_json(url)
    actual = payload.get("message")
    if actual != expected_message:
        raise RuntimeError(
            f"Unexpected message from {url}: expected '{expected_message}', got '{actual}'"
        )


def check_ecr_repository(repo_name: str, region: str) -> None:
    cmd = [
        "aws",
        "ecr",
        "describe-repositories",
        "--repository-names",
        repo_name,
        "--region",
        region,
        "--query",
        "repositories[0].repositoryUri",
        "--output",
        "text",
    ]
    try:
        result = subprocess.run(
            cmd,
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError as exc:
        raise RuntimeError("aws CLI not found in PATH") from exc
    except subprocess.CalledProcessError as exc:
        stderr = (exc.stderr or "").strip()
        raise RuntimeError(
            f"ECR repository check failed for '{repo_name}': {stderr}"
        ) from exc

    repo_uri = result.stdout.strip()
    if not repo_uri or repo_uri == "None":
        raise RuntimeError(f"ECR repository URI missing for '{repo_name}'")


def main() -> int:
    alb_dns = (
        sys.argv[1]
        if len(sys.argv) > 1
        else os.getenv("ALB_DNS", DEFAULT_ALB_DNS)
    )
    region = (
        sys.argv[2]
        if len(sys.argv) > 2
        else os.getenv("AWS_REGION", os.getenv("REGION", DEFAULT_REGION))
    )

    print(f"Using ALB_DNS={alb_dns}")
    print(f"Using REGION={region}")

    try:
        assert_message(f"http://{alb_dns}/service1", "Hello from Service 1")
        assert_message(f"http://{alb_dns}/service2", "Hello from Service 2")
        check_ecr_repository("service1", region)
        check_ecr_repository("service2", region)
    except RuntimeError as exc:
        print(f"Verification failed: {exc}", file=sys.stderr)
        return 1

    print("All checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
