# 07 — Azure Monitor: Notify on VM4 Configuration Changes

**Status: Designed and scripted only — no Azure deployment or email delivery has been verified.**

## Case-study requirement

> Create a workflow to send an email message when the settings of VM4 are modified.

## Proposed solution

Use an **Azure Monitor Activity Log alert** targeting Azure VM4 resource **write** events, linked to an **action group email receiver**. The action group provides email delivery without needing a separate Logic App or custom application.

### Scope and limits

- A control-plane write operation such as `Microsoft.Compute/virtualMachines/write` can indicate an update through Azure Resource Manager.
- The case does **not** define precisely which VM4 setting must be detected. This example matches **VM resource writes**. It can also match VM creation and some management operations and is **not proof of an actual configuration difference**.
- Changes inside the guest operating system (e.g. editing Linux `/etc/ssh/sshd_config`) are **not** captured by Activity Log and would require guest monitoring, change tracking and appropriate agents.
- Changes to linked resources such as NICs/disks/NSGs or VM extensions may use **different** resource IDs and operation names. Add distinct alert rules if they are within scope.
- Alert delivery is asynchronous, not guaranteed instantaneous. Action group email receivers may require address confirmation and must be tested.

## Bicep artifacts

[**`infrastructure/bicep/monitoring/main.bicep`**](../infrastructure/bicep/monitoring/main.bicep)

Deploys:
1. `Microsoft.Insights/actionGroups` with an email receiver.
2. `Microsoft.Insights/activityLogAlerts` filtering administrative VM4 write events to its exact resource ID.

VM4 is declared as an **existing** Azure VM. The template **does not create VM4**, preventing additional VM charges. The alert rule itself is scoped to VM4.

## Linux/Bash runbook

### Pre-flight (read-only)

Verify subscription and VM4 details:

```bash
az account show --query '{Name:name,Subscription:id}' -o table
az vm show -g rg-xfusioncorp-az104 -n vm4 --query '{Name:name,Id:id,Location:location}' -o json
```

Both `rg-xfusioncorp-az104` and `vm4` are **simulation placeholders**; replace with actual resource identifiers.

### Local Bicep compilation and safe preview

```bash
az bicep build --file infrastructure/bicep/monitoring/main.bicep

az deployment group what-if \
  -g rg-xfusioncorp-az104 \
  -f infrastructure/bicep/monitoring/main.bicep \
  -p vm4Name=vm4 notificationEmail='YOUR_VERIFIED_EMAIL@example.com'
```

The example uses a deliberately invalid placeholder email; replace it with a **real authorised destination** before deployment.

### Deploy only after permissions and email are approved

```bash
az deployment group create \
  -g rg-xfusioncorp-az104 \
  -f infrastructure/bicep/monitoring/main.bicep \
  -p vm4Name=vm4 notificationEmail='YOUR_VERIFIED_EMAIL@example.com'
```

### Inspect alert state and activity without modifying resources

```bash
bash infrastructure/scripts/check-vm4-alert.sh rg-xfusioncorp-az104 vm4
```

### Acceptance test (controlled change)

1. Confirm action group email receiver and rule are **Enabled**.
2. Perform an **authorised** harmless change to VM4's Azure resource properties during a test window, such as adding/removing a test tag. First verify that this change generates a `Microsoft.Compute/virtualMachines/write` record (tag-only updates may be logged differently depending on API).
3. Check VM4's Activity Log for the matching operation and review alert history.
4. Confirm the recipient receives an email with VM4 as the target. If not, examine rule scope/filter, action group email verification, alert delay and policy restrictions.
5. Record actual time, operation, rule details and redacted evidence; revert any temporary test configuration.

**No live test is claimed.**

## Permissions and cost

- Creating and maintaining alert rules/action groups requires Azure Monitor and resource-group write permissions.
- Monitoring/notification may incur charges based on Azure Monitor pricing and delivery channel; confirm costs in the chosen subscription.
- This is suitable for a low-dependency AZ-104 workflow; avoid expensive Log Analytics solutions unless broader guest-level monitoring is required.

## Sources

- https://learn.microsoft.com/en-us/azure/azure-monitor/platform/activity-log
- https://learn.microsoft.com/en-us/azure/azure-monitor/platform/alerts-activity-log
- https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2020-10-01/activitylogalerts
- https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2023-01-01/actiongroups
