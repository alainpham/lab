#!/bin/sh
# certbot dns-01 hook for IONOS DNS: creates (and deletes) the _acme-challenge TXT record.
#
# API: https://api.hosting.ionos.com/dns/v1 - see https://developer.hosting.ionos.de/docs/dns
# Needs curl, dig and python3, all present in the image built from ./Dockerfile.
#
# Environment:
#   IONOS_API_KEY              "<publicprefix>.<secret>" from https://developer.hosting.ionos.de
#                              (or set IONOS_API_PREFIX + IONOS_API_SECRET instead)
#   IONOS_TTL                  ttl of the challenge record, default 60
#   IONOS_PROPAGATION_SECONDS  how long to wait for the record to become visible, default 60
#
# Certbot passes CERTBOT_DOMAIN and CERTBOT_VALIDATION.
#
# Usage:
#   certbot certonly --preferred-challenges dns --authenticator manual \
#     --manual-auth-hook "/auth.sh" --manual-cleanup-hook "/auth.sh cleanup" -d "*.example.com"

set -eu

API=https://api.hosting.ionos.com/dns/v1
TTL=${IONOS_TTL:-60}
PROPAGATION=${IONOS_PROPAGATION_SECONDS:-60}

log() { echo "auth.sh: $*"; }
die() { echo "auth.sh: $*" >&2; exit 1; }

mode=auth
case "$(basename "$0")" in *cleanup*) mode=cleanup ;; esac
case "${1:-}" in auth|"") ;; cleanup) mode=cleanup ;; *) die "unknown argument: $1" ;; esac

if [ -z "${IONOS_API_KEY:-}" ]; then
  [ -n "${IONOS_API_PREFIX:-}" ] && [ -n "${IONOS_API_SECRET:-}" ] \
    || die "set IONOS_API_KEY (or IONOS_API_PREFIX and IONOS_API_SECRET)"
  IONOS_API_KEY="${IONOS_API_PREFIX}.${IONOS_API_SECRET}"
fi
[ -n "${CERTBOT_DOMAIN:-}" ] || die "CERTBOT_DOMAIN is not set"

# a wildcard cert is validated on the base domain
domain=$(echo "$CERTBOT_DOMAIN" | sed -e 's/^\*\.//' -e 's/\.$//')
record="_acme-challenge.${domain}"

body=$(mktemp)
trap 'rm -f "$body"' EXIT

# api <method> <path> [json] - response body lands in $body
api() {
  _method=$1; _path=$2; _json=${3:-}
  if [ -n "$_json" ]; then
    _code=$(curl -sS -o "$body" -w '%{http_code}' -X "$_method" "${API}${_path}" \
      -H "X-API-Key: ${IONOS_API_KEY}" -H 'Accept: application/json' \
      -H 'Content-Type: application/json' -d "$_json")
  else
    _code=$(curl -sS -o "$body" -w '%{http_code}' -X "$_method" "${API}${_path}" \
      -H "X-API-Key: ${IONOS_API_KEY}" -H 'Accept: application/json')
  fi
  case "$_code" in
    2*) return 0 ;;
    *) die "$_method $_path returned HTTP $_code: $(cat "$body")" ;;
  esac
}

# the zone is the longest of our zone names that $domain sits in
api GET /zones
zone_id=$(python3 -c '
import json, sys
domain = sys.argv[2].lower()
best = None
with open(sys.argv[1]) as f:
    for zone in json.load(f):
        name = zone.get("name", "").rstrip(".").lower()
        if name and (domain == name or domain.endswith("." + name)):
            if best is None or len(name) > len(best[0]):
                best = (name, zone["id"])
if best is None:
    sys.exit(1)
print(best[1])
' "$body" "$domain") || die "no IONOS zone covers ${domain}"

# record ids of the challenge records in this zone, optionally only the one holding $1
challenge_record_ids() {
  api GET "/zones/${zone_id}?recordName=${record}&recordType=TXT"
  python3 -c '
import json, sys
name, content = sys.argv[2], sys.argv[3]
with open(sys.argv[1]) as f:
    for record in json.load(f).get("records", []):
        if record.get("name", "").rstrip(".").lower() != name:
            continue
        if record.get("type") != "TXT":
            continue
        if content and record.get("content", "").strip("\"") != content:
            continue
        print(record["id"])
' "$body" "$record" "${1:-}"
}

case "$mode" in

auth)
  [ -n "${CERTBOT_VALIDATION:-}" ] || die "CERTBOT_VALIDATION is not set"

  # POST adds records, so several challenges can be pending on the same name at once
  api POST "/zones/${zone_id}/records" "$(python3 -c '
import json, sys
print(json.dumps([{"name": sys.argv[1], "type": "TXT", "content": sys.argv[2],
                   "ttl": int(sys.argv[3]), "disabled": False}]))
' "$record" "$CERTBOT_VALIDATION" "$TTL")"
  log "added TXT ${record} = ${CERTBOT_VALIDATION}"

  # ask the zone's own nameserver, so nothing can be answered from a cache
  ns=$(api GET "/zones/${zone_id}?recordType=NS" && python3 -c '
import json, sys
with open(sys.argv[1]) as f:
    for record in json.load(f).get("records", []):
        if record.get("type") == "NS":
            print(record.get("content", "").rstrip("."))
            break
' "$body")

  # busybox nslookup cannot query TXT, so without dig we can only wait
  if ! command -v dig >/dev/null 2>&1; then
    log "dig not available, waiting ${PROPAGATION}s"
    sleep "$PROPAGATION"
  else
    lookup="dig +short TXT ${record}${ns:+ @$ns}"
    waited=0
    while : ; do
      if $lookup 2>/dev/null | grep -qF "$CERTBOT_VALIDATION"; then
        log "record visible${ns:+ on $ns} after ${waited}s"
        break
      fi
      if [ "$waited" -ge "$PROPAGATION" ]; then
        log "record still not visible${ns:+ on $ns} after ${waited}s, continuing anyway"
        break
      fi
      sleep 5
      waited=$((waited + 5))
    done
  fi
  ;;

cleanup)
  ids=$(challenge_record_ids "${CERTBOT_VALIDATION:-}")
  [ -n "$ids" ] || { log "no TXT ${record} to delete"; exit 0; }
  for id in $ids; do
    api DELETE "/zones/${zone_id}/records/${id}"
    log "deleted TXT ${record} (${id})"
  done
  ;;

esac
