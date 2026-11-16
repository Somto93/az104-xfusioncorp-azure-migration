#!/usr/bin/env bash
set -euo pipefail

# Read-only checks for an EXISTING Azure VM4 and its Activity Log alert.
# Usage: bash infrastructure/scripts/check-vm4-alert.sh <resource-group> <vm-name>
# No Azure resources are created or modified.

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <resource-group> <vm-name>" >&2
  exit 2
fi

command -v az >/dev/null || { echo "Azure CLI ('az') is required" >&2; exit 1; }

RG="$1"
VM="$2"

echo "Active subscription:"
az account show --query '{Subscription:id,Name:name}' -o table

VM_ID="$(az vm show --resource-group "$RG" --name "$VM" --query id -o tsv)"
if [[ -z "$VM_ID" ]]; then
  echo "Could not find VM $VM in resource group $RG" >&2
  exit 1
fi

echo
echo "VM ID: $VM_ID"
echo
echo "VM4 Activity Log alert rules:"
az monitor activity-log alert list --resource-group "$RG" \
  --query "[].{Name:name,Enabled:enabled,Scopes:scopes}" -o json

echo
echo "Email action group (receiver addresses may appear in output; redact before publication):"
az monitor action-group show \
  --resource-group "$RG" \
  --name ag-xfusion-vm4-email \
  --query '{Name:name,Enabled:enabled,EmailReceivers:emailReceivers[].name}' -o json

echo
echo "Recent Azure VM write events (up to 7 days):"
az monitor activity-log list --resource-id "$VM_ID" --offset 7d \
  --query "[?operationName.value=='Microsoft.Compute/virtualMachines/write'].{Time:eventTimestamp,Operation:operationName.value,Status:status.value}" \
  --output table

echo
echo "Read-only validation complete. This does not confirm that any email was delivered."
