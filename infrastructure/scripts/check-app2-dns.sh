#!/usr/bin/env bash
set -euo pipefail
# Read-only DNS inspection. Requires the public domain's DNS to be configured.
# Usage: bash infrastructure/scripts/check-app2-dns.sh app2.xFusionCorp.com

FQDN="${1:-app2.xFusionCorp.com}"
command -v dig >/dev/null || { echo "Install dig (dnsutils/bind-utils) to test DNS." >&2; exit 1; }
echo "Checking CNAME for $FQDN:"
dig +short CNAME "$FQDN"
echo
echo "Checking TXT verification record for asuid.$FQDN:"
dig +short TXT "asuid.$FQDN"
echo
echo "These lookups alone do not establish App Service hostname binding or HTTPS certificate validity."
