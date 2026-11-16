#!/usr/bin/env bash
set -euo pipefail
# Read-only resource inspection. No Azure resources are created.
# Usage: bash infrastructure/scripts/check-app-service.sh <resource-group>
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <resource-group>" >&2
  exit 2
fi
command -v az >/dev/null || { echo "az CLI required" >&2; exit 1; }

RG="$1"
if [[ "$(az group exists --name "$RG")" != "true" ]]; then
  echo "Resource group '$RG' not found in current subscription" >&2
  exit 1
fi

echo "Active subscription:"
az account show --query '{Id:id,Name:name}' -o table
echo
echo "App Service plans:"
az appservice plan list --resource-group "$RG" \
  --query '[].{Name:name,Tier:sku.tier,Sku:sku.name,Workers:sku.capacity,Kind:kind}' -o table
echo
echo "Web apps:"
az webapp list --resource-group "$RG" \
  --query '[].{Name:name,State:state,DefaultHostname:defaultHostName,Plan:serverFarmId}' -o table
echo
echo "Azure Monitor autoscale configurations:"
az monitor autoscale list --resource-group "$RG" \
  --query '[].{Name:name,Enabled:enabled,Target:targetResourceUri,Minimum:profiles[0].capacity.minimum,Maximum:profiles[0].capacity.maximum}' -o table

echo "Inspection complete; deployment and autoscale operation remain unverified until tested."
