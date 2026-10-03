#!/usr/bin/env bash
# Fire N concurrent Lambda invocations to demonstrate concurrency.
# usage: ./burst.sh [count]    (default: 10)
set -euo pipefail

N="${1:-10}"

echo "Sending $N concurrent invocations..."

for i in $(seq 1 "$N"); do
  ./invoke.sh "burst request $i" &
done

wait
echo "Done — compare env_id values to see how many execution environments were used."
