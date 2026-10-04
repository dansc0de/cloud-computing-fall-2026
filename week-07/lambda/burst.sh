#!/usr/bin/env bash
# fire N concurrent Lambda invocations to demonstrate concurrency.
# usage: ./burst.sh [count]    (default: 10)
set -euo pipefail

FN="${FN:-lambda-cost-usage}"
N="${1:-10}"

invoke() {
  local i="$1"
  local out
  out="$(mktemp)"

  aws lambda invoke \
    --function-name "$FN" \
    --cli-binary-format raw-in-base64-out \
    --payload "{\"message\": \"burst request $i\"}" \
    --log-type Tail \
    --query LogResult --output text \
    "$out" > /dev/null 2>&1

  local env_id invocations cold_start
  env_id="$(jq -r .env_id "$out")"
  invocations="$(jq -r .invocations_in_env "$out")"
  cold_start="$(jq -r .cold_start "$out")"
  rm -f "$out"

  printf "  returned #%2d  env=%s  invocations=%s  cold_start=%s\n" \
    "$i" "$env_id" "$invocations" "$cold_start"
}

echo "sending $N concurrent invocations..."
echo ""

for i in $(seq 1 "$N"); do
  invoke "$i" &
done

wait

echo ""
echo "- requests return out of order — each runs in its own sandbox"
echo "- same env_id = reused execution environment (warm start)"
echo "- invocations_in_env shows each environment's private counter"
