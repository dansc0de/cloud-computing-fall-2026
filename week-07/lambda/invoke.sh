#!/usr/bin/env bash
# Invoke the Lambda function and print the response + REPORT line.
# usage: ./invoke.sh "your message here"
set -euo pipefail

FN="${FN:-lambda-cost-usage}"
MSG="${1:-hello from itcc}"
OUT="$(mktemp)"

aws lambda invoke \
  --function-name "$FN" \
  --cli-binary-format raw-in-base64-out \
  --payload "{\"message\": \"$MSG\"}" \
  --log-type Tail \
  --query LogResult --output text \
  "$OUT" | base64 -d | grep -E "REPORT|Task timed out|ERROR" || true

python3 -m json.tool "$OUT"
rm -f "$OUT"
