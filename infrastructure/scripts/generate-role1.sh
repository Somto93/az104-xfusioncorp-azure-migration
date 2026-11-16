#!/usr/bin/env bash
set -euo pipefail

# Generate a Reader-equivalent Azure RBAC custom role named Role1.
# This script reads Azure metadata and writes a local file ONLY.
# It does not create or assign any Azure role.
#
# Usage:
#   az login
#   az account set --subscription "<subscription-id>"
#   bash infrastructure/scripts/generate-role1.sh
#   cat role1.generated.json

command -v az >/dev/null || { echo "Azure CLI is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "Python 3 is required" >&2; exit 1; }

SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "No active Azure subscription. Use az login / az account set." >&2
  exit 1
fi

export SUBSCRIPTION_ID
# Query the installed Reader definition, rather than copying guessed privileges.
az role definition list --name Reader -o json |
python3 -c '
import json, os, sys
roles = json.load(sys.stdin)
reader = next((r for r in roles if r.get("roleName") == "Reader"), None)
if reader is None:
    sys.exit("The Reader role could not be located.")
perms = reader.get("permissions")
if not perms:
    sys.exit("Reader has no permission arrays in the returned definition.")
role = {
    "Name": "Role1",
    "IsCustom": True,
    "Description": "Reader-equivalent custom role for the AZ-104 xFusionCorp case study.",
    "Actions": perms[0].get("actions", []),
    "NotActions": perms[0].get("notActions", []),
    "DataActions": perms[0].get("dataActions", []),
    "NotDataActions": perms[0].get("notDataActions", []),
    "AssignableScopes": ["/subscriptions/" + os.environ["SUBSCRIPTION_ID"]]
}
with open("role1.generated.json", "w", encoding="utf-8") as f:
    json.dump(role, f, indent=2)
    f.write("\n")
print("Wrote role1.generated.json — review it before any deployment.")
'
