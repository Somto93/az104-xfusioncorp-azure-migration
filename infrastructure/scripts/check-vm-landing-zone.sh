#!/usr/bin/env bash
set -euo pipefail

# Read-only Azure landing-zone inventory for the AZ-104 case study.
# Usage: bash infrastructure/scripts/check-vm-landing-zone.sh <resource-group>
# Does not discover on-premises VMs or create Azure resources.

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <resource-group>" >&2
  exit 2
fi
command -v az >/dev/null || { echo "Azure CLI is not installed." >&2; exit 1; }

RG="$1"
echo "Current Azure context:"
az account show --query '{Subscription:id,Tenant:tenantId}' -o table
echo
echo "Checking resource group: $RG"
if [[ "$(az group exists --name "$RG")" != "true" ]]; then
  echo "Resource group '$RG' does not exist in the current subscription." >&2
  exit 1
fi

echo
echo "Azure VMs:"
az vm list --resource-group "$RG" --query '[].{Name:name,Location:location,Size:hardwareProfile.vmSize,Provisioning:provisioningState}' -o table

echo
echo "Virtual networks:"
az network vnet list --resource-group "$RG" --query '[].{Name:name,Location:location,AddressPrefixes:addressSpace.addressPrefixes}' -o table

echo
echo "Network security groups:"
az network nsg list --resource-group "$RG" --query '[].{Name:name,Location:location}' -o table

echo
echo "Read-only inventory complete. No resources were modified."
