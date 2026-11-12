#!/usr/bin/env bash
# Asks the Hetzner Cloud API in which locations a server type can be ordered right now.
#
# Writes two step outputs to $GITHUB_OUTPUT (or stdout when run locally):
#   available=true|false
#   locations=hel1,nbg1   (comma-separated, empty when none)
#
# Env:
#   HCLOUD_TOKEN     Hetzner Cloud API token, read-only is enough (required unless FORCE_AVAILABLE)
#   SERVER_TYPE      server type name, default cx23
#   FORCE_AVAILABLE  "true" skips the API and pretends the type is available (tests the mail path)
#
# Exit code 1 means "could not tell" (API down, token wrong, type renamed),
# never "not available". GitHub then emails a failed-run notice.
set -euo pipefail

SERVER_TYPE="${SERVER_TYPE:-cx23}"
OUT="${GITHUB_OUTPUT:-/dev/stdout}"

if [[ "${FORCE_AVAILABLE:-false}" == "true" ]]; then
  echo "FORCE_AVAILABLE=true: skipping the API, pretending ${SERVER_TYPE} is available"
  {
    echo "available=true"
    echo "locations=TEST"
  } >> "$OUT"
  exit 0
fi

: "${HCLOUD_TOKEN:?HCLOUD_TOKEN is not set (repo secret missing?)}"

body="$(curl --silent --show-error --fail-with-body \
  --retry 3 --retry-delay 5 --max-time 20 \
  -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
  "https://api.hetzner.cloud/v1/server_types?name=${SERVER_TYPE}")"

count="$(jq '.server_types | length' <<<"$body")"
if [[ "$count" -ne 1 ]]; then
  echo "::error::Expected exactly 1 server type named '${SERVER_TYPE}', got ${count}"
  exit 1
fi

# locations[].available is false while the type is temporarily sold out in that location.
locations="$(jq -r '[.server_types[0].locations[] | select(.available == true) | .name] | join(",")' <<<"$body")"
all="$(jq -r '[.server_types[0].locations[].name] | join(",")' <<<"$body")"

echo "${SERVER_TYPE}: offered in [${all}], available in [${locations:-none}]"

if [[ -n "$locations" ]]; then
  echo "available=true" >> "$OUT"
else
  echo "available=false" >> "$OUT"
fi
echo "locations=${locations}" >> "$OUT"
