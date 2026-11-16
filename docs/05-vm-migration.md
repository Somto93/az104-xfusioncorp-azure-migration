# 05 — VM Migration: Server1 and Server2

**Status: Designed only. No source VMs discovered and no migration run.**

## What we know / do not know

The case says xFusionCorp will migrate VMs hosted on `Server1` and `Server2` into Azure. Two referenced inventory tables are unavailable. We **do not know** the hypervisor (VMware, Hyper-V or other), number of guest VMs, OS versions, CPU/RAM, storage, RPO/RTO, dependencies or Azure subscription quota.

Therefore, **do not assume** Server1 and Server2 are Hyper-V hosts, or that they themselves should be migrated. Inventory first.

## Migration decision tree

| Source platform | Preferred workflow | Note |
| --- | --- | --- |
| VMware vSphere | Azure Migrate appliance for discovery/assessment; VMware agentless migration if supported | Requires vCenter access and compatible platform |
| Hyper-V | Azure Migrate appliance for discovery/assessment; Hyper-V replication provider for migration | Replication provider runs on hosts |
| Other hypervisor / physical | Azure Migrate physical/other-server workflow | Replication appliance and mobility agent may be required |

**Platform-dependent appliances cannot simply be replaced with a Linux Bash script.** We will use Linux/CLI for inventory, Azure-side checks and validation, and document appliance steps required by Microsoft.

## Runbook (production design; not executed)

### 1. Discover and classify

- Get source hypervisor, guest VM inventory, OS versions, vCPU, RAM, disks and performance data.
- Map app-to-VM, database, identity/DNS, ports, network and storage dependencies.
- Check unsupported guest OS, disk and boot configurations.
- Document service owners, recovery requirements, change windows and business rollback approvals.
- Capture a reproducible baseline.

### 2. Set up Azure Migrate project

- Choose a supported Azure Migrate project geography (metadata storage) independently of the chosen target VM region.
- Deploy discovery/assessment appliance matching **confirmed** source platform.
- Discover servers and assess Azure readiness, right-sized targets and estimated costs.
- Review findings, network/subnet placement, security rules and IP/DNS change requirements.

### 3. Prepare target Azure landing zone

- Verify tenant/subscription access, quotas, policy and allowed regions/SKUs.
- Prepare resource groups, VNet, NSGs, connectivity, DNS, storage and access controls.
- Plan backup, security baseline, monitoring and supported disk options.

### 4. Replicate and test

- Choose agentless/agent-based mode based on assessment and supported source.
- Enable replication in Azure Migrate.
- Perform **test migration** in an isolated test subnet; validate boot, agent status, application services, database connections, monitoring, DNS and port reachability.
- Record defects and revise the runbook.

### 5. Cutover with rollback plan

- Secure application-owner approval and maintenance window.
- Quiesce application writes if necessary; final sync and migration cutover.
- Update DNS, routes, firewalls and downstream integrations using measured changes.
- Validate business functionality and performance, not merely VM power state.
- Keep an approved rollback strategy until the cutover is accepted; do not delete source machines prematurely.

### 6. Post-migration

- Configure backup, patching, Azure Monitor, cost tags and alerts.
- Right-size after measuring utilisation; audit temporary storage and unused resources.
- Record final architecture, decisions, evidence and lessons learned.

## Linux-first verification commands (read-only)

Run only in an Azure account you are authorised to inspect. File: [`infrastructure/scripts/check-vm-landing-zone.sh`](../infrastructure/scripts/check-vm-landing-zone.sh).

```bash
az login
az account show --query '{Subscription:id,Tenant:tenantId}' -o table
bash infrastructure/scripts/check-vm-landing-zone.sh rg-xfusioncorp-az104
```

This inventory checks an existing Azure resource group, its deployed VMs, VNet and NSGs. It **does not create**, discover or migrate on-premises VMs. The proposed resource group name is a simulation placeholder.

## Evidence checklist

| Item | Required evidence | Current status |
| --- | --- | --- |
| Source inventory | Server1/Server2 host details, guest VMs | Missing |
| Azure Migrate project | Project configuration and access | Not deployed |
| Assessment | Compatibility, size and cost report | Not executed |
| Replication | Replication health and status | Not executed |
| Test migration | Boot and application checks | Not executed |
| Cutover | Change record, test results, rollback evidence | Not executed |
| Post-cutover | Backup, monitoring, cost baseline | Not executed |

## Lab boundaries

KodeKloud may disallow resources or delete them through lab automation. Never state that a proposed Azure Migrate workflow succeeded unless real evidence exists. Avoid deploying billable VM resources merely to populate screenshots.

## Microsoft documentation (consult at execution time)

- [Azure Migrate overview](https://learn.microsoft.com/en-us/azure/migrate/migrate-services-overview)
- [Prepare machines for migration](https://learn.microsoft.com/en-us/azure/migrate/prepare-for-migration)
- [Discover VMware servers](https://learn.microsoft.com/en-us/azure/migrate/tutorial-discover-vmware)
- [Migrate VMware VMs](https://learn.microsoft.com/en-us/azure/migrate/tutorial-migrate-vmware)
- [Migrate physical / other virtualised servers](https://learn.microsoft.com/en-us/azure/migrate/tutorial-migrate-physical-virtual-machines)
